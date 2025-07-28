import Foundation
import CryptoKit


















public class MySQLClient: DBClient {
    
    /*deinit {
     close(self.socket)
 }*/
    
    private func readHandshakeInitPacket() {
        var buffer = [UInt8](repeating: 0, count: 256) // Etwas mehr Puffer schadet nicht
        let bytesRead = recv(socket, &buffer, buffer.count, 0)
        
        guard bytesRead > 0 else {
            print("❌ Kein Handshake erhalten")
            return
        }
        
        print("📥 Handshake empfangen: \(bytesRead) Bytes")
        
        var offset = 4 // Start nach dem Paket-Header
        
        // 1. Protokoll-Version (1 Byte)
        let protocolVersion = buffer[offset]
        print("🔢 Protokoll-Version: \(protocolVersion)")
        offset += 1
        
        // 2. Server-Version (Null-terminierter String)
        guard let nullIndex = buffer[offset...].firstIndex(of: 0) else {
            print("❌ Server-Version nicht gefunden")
            return
        }
        let versionBytes = buffer[offset..<nullIndex]
        if let serverVersion = String(bytes: versionBytes, encoding: .utf8) {
            print("🧠 Server-Version: \(serverVersion)")
        }
        offset = nullIndex + 1 // Gehe zum Byte nach der Null
        
        // 3. Connection ID (4 Bytes)
        offset += 4
        
        // 4. Erster Teil des Salts (auth_plugin_data_part_1, 8 Bytes)
        let salt1 = Array(buffer[offset..<offset + 8])
        offset += 8
        
        // 5. Filler (1 Byte) & Capability Flags (2 Bytes)
        offset += 1 // Filler
        offset += 2 // Capability Flags (untere 2 Bytes)
        
        // 6. Character Set (1 Byte) & Status Flags (2 Bytes)
        offset += 1 // Character Set
        offset += 2 // Status Flags
        
        // 7. Capability Flags (obere 2 Bytes)
        offset += 2 // Capability Flags (obere 2 Bytes)
        
        // 8. Länge des Auth-Plugin-Data (1 Byte) ODER 0
        let authPluginDataLength = Int(buffer[offset])
        offset += 1
        
        // 9. Reservierte Bytes (10 Bytes)
        offset += 10
        
        // 10. Zweiter Teil des Salts (auth_plugin_data_part_2, max 12 Bytes, muss null-terminiert sein)
        // Die Länge ist authPluginDataLength - 8 (da Teil 1 schon 8 Bytes hatte), aber mind. 12 Bytes.
        let salt2End = offset + max(13, authPluginDataLength - 8) - 1
        let salt2Bytes = buffer[offset..<salt2End]
        let salt2 = Array(salt2Bytes)
        offset = salt2End + 1 // +1 für das Null-Byte
        
        self.salt = salt1 + salt2
        print("🧂 Salt extrahiert: \(self.salt.count) Bytes")
        
        // 11. Auth Plugin Name (Null-terminierter String)
        if let authPluginNullIndex = buffer[offset...].firstIndex(of: 0) {
            let pluginBytes = buffer[offset..<authPluginNullIndex]
            if let pluginName = String(bytes: pluginBytes, encoding: .utf8) {
                print("🔐 Vom Server angeforderter Auth-Plugin: \(pluginName)")
                // HIER solltest du prüfen, ob es wirklich "mysql_native_password" ist!
            }
        }
    }
    /*
     public func login(username: String, password: String, database: String) -> MySQLClient {
     
     let payload = SQLClientHelper.buildPayload(username, password, salt, database: database)
     
     let header = SQLClientHelper.buildHeader(length: UInt32(payload.count))
     
     let fullPacket = header + payload
     let sent = send(socket, fullPacket, fullPacket.count, 0)
     if sent < 0 {
     perror("❌ Login-Paket senden fehlgeschlagen")
     return self
     }
     
     print("📤 Login-Paket gesendet")
     
     var response = [UInt8](repeating: 0, count: 1024)
     let received = recv(socket, &response, response.count, 0)
     guard received > 0 else {
     print("❌ Keine Antwort nach Login erhalten")
     return self
     }
     
     let firstByte = response[4]
     switch firstByte {
     case 0x00:
     print("✅ Login erfolgreich")
     case 0xFF:
     print("❌ Login-Fehler")
     decodeMySQLError(response)
     default:
     print("❓ Unbekannte Login-Antwort: \(firstByte)")
     }
     
     return self
     }
     */
    
    public func login(username: String, password: String) {
        
        let payload: [UInt8] = []
        
        let header = SQLClientHelper.buildHeader(length: UInt32(payload.count))
        
        let fullPacket = header + payload
        let sent = send(socket, fullPacket, fullPacket.count, 0)
        if sent < 0 {
            perror("❌ Login-Paket senden fehlgeschlagen")
            return
        }
        
        print("📤 Login-Paket gesendet")
        
        var response = [UInt8](repeating: 0, count: 1024)
        let received = recv(socket, &response, response.count, 0)
        guard received > 0 else {
            print("❌ Keine Antwort nach Login erhalten")
            return
        }
        
        let firstByte = response[4]
        switch firstByte {
        case 0x00:
            print("✅ Login erfolgreich")
        case 0xFF:
            print("❌ Login-Fehler")
            decodeMySQLError(response)
        default:
            print("❓ Unbekannte Login-Antwort: \(firstByte)")
        }
    }
    
    private func readPacket() -> (payload: [UInt8], sequenceId: UInt8)? {
        
        var header = [UInt8](repeating: 0, count: 4)
        
        // 1. Lese den 4-Byte-Header
        guard recv(socket, &header, 4, 0) == 4 else {
            perror("❌ Fehler beim Lesen des Paket-Headers")
            return nil
        }
        
        let payloadLength = Int(header[0]) | (Int(header[1]) << 8) | (Int(header[2]) << 16)
        let sequenceId = header[3]
        
        // 2. Lese den Payload basierend auf der Länge aus dem Header
        var payload = [UInt8](repeating: 0, count: payloadLength)
        if payloadLength > 0 {
            guard recv(socket, &payload, payloadLength, 0) == payloadLength else {
                perror("❌ Fehler beim Lesen des Payloads")
                return nil
            }
        }
        
        return (payload, sequenceId)
    }
    
    // ÜBERARBEITETE sendQuery-Funktion
    public func sendQuery(_ sql: String) {
        let command: UInt8 = 0x03 // COM_QUERY
        let queryData = Array(sql.utf8)
        
        let payload = [command] + queryData
        let length = UInt32(payload.count)
        
        // Sequenz-ID für einen neuen Befehl ist immer 0
        let header: [UInt8] = [
            UInt8(length & 0xFF),
            UInt8((length >> 8) & 0xFF),
            UInt8((length >> 16) & 0xFF),
            0x00
        ]
        
        let fullPacket = header + payload
        guard send(socket, fullPacket, fullPacket.count, 0) >= 0 else {
            perror("❌ Query senden fehlgeschlagen")
            return
        }
        
        print("📤 Query gesendet: \(sql)")
        
        // Neue Funktion, die den Antwort-Strom verarbeitet
        readQueryResult()
    }
    
    // NEUE FUNKTION: Verarbeitet den mehrteiligen Antwort-Strom
    private func readQueryResult() {
        // 1. Lese das erste Antwort-Paket. Das sagt uns, was zu erwarten ist.
        guard var (firstPayload, _) = readPacket() else { return }
        
        switch firstPayload[0] {
        case 0x00:
            print("✅ OK-Paket erhalten (z.B. für INSERT, UPDATE)")
            return
        case 0xFF:
            print("❌ Fehler-Paket erhalten")
            decodeMySQLError(firstPayload)
            return
        default:
            // Dies ist ein Result-Set (z.B. von einem SELECT)
            print("📦 Result-Set wird verarbeitet...")
            parseResultSet(firstPacketPayload: &firstPayload)
        }
    }
    
    private func parseResultSet(firstPacketPayload: inout [UInt8]) {
        // Der erste Payload enthält die Spaltenanzahl.
        // Wir verwenden einen eigenen Lese-Offset für den Payload.
        var payloadOffset = 0
        let columnCount = Int(firstPacketPayload[payloadOffset]) // Dies ist eine vereinfachte Annahme, eigentlich ist es ein Length-Encoded Integer
        payloadOffset += 1
        print("🏛️ Spaltenanzahl: \(columnCount)")
        
        // 2. Lese die Definition für jede Spalte (jedes ist ein eigenes Paket)
        for i in 1...columnCount {
            guard let (colPayload, _) = readPacket() else { return }
            // In einer echten Implementierung würdest du hier die Spalten-Infos (Name, Typ etc.) speichern.
            print("  - Spaltendefinition \(i) gelesen: \(colPayload.count) Bytes")
        }
        
        // 3. Lese das EOF-Paket nach den Spaltendefinitionen
        guard let (eof1, _) = readPacket(), eof1[0] == 0xFE else {
            print("❌ EOF-Paket nach Spalten nicht gefunden")
            return
        }
        print("🏁 EOF nach Spaltendefinitionen erhalten.")
        
        // 4. Lese die Datenzeilen, bis das finale EOF-Paket kommt
        var rows: [[String]] = []
        while true {
            guard let (rowPacket, _) = readPacket() else { break }
            
            if rowPacket[0] == 0xFE { // Finales EOF-Paket?
                print("🏁 Finales EOF-Paket erhalten. Ende des Result-Sets.")
                break
            }
            
            // Parse die einzelne Zeile (sehr vereinfacht!)
            // Eine echte Implementierung ist hier viel komplexer.
            if let rowString = String(bytes: rowPacket, encoding: .utf8) {
                // Diese einfache Umwandlung funktioniert nur, wenn die Zeile nur eine Spalte hat.
                rows.append([rowString])
            }
        }
        
        print("✅ Ergebnis: \(rows.count) Zeilen gefunden.")
        rows.forEach { row in
            print(row)
        }
        
    }
    
}

func decodeMySQLError(_ response: [UInt8]) {
    
    if response.count >= 6 {
        let errorCode = UInt16(response[5]) | (UInt16(response[6]) << 8)
        print("🧾 Error-Code: \(errorCode)")
    }
    
    // Suche nach SQL State Marker + Error Message
    let sqlStateMarkerIndex = 7
    let sqlStateCode = response.count >= sqlStateMarkerIndex + 5
    ? String(bytes: response[sqlStateMarkerIndex..<sqlStateMarkerIndex + 5], encoding: .utf8) ?? "N/A"
    : "N/A"
    
    print("🪪 SQL-Status: \(sqlStateCode)")
    
    // Fehlertext extrahieren
    let messageStart = sqlStateMarkerIndex + 5
    if response.count > messageStart {
        let messageBytes = response[messageStart..<response.count]
        if let message = String(bytes: messageBytes, encoding: .utf8) {
            print("❌ Fehlertext: \(message)")
        } else {
            print("❌ Fehlertext konnte nicht dekodiert werden")
        }
    } else {
        print("❌ Keine Fehlernachricht enthalten")
    }
}

///Adding QueryBuilder to Client

extension MySQLClient{
    
    public func query(on table: String) -> QueryBuilder{
        return QueryBuilder(table: table, database: self)
    }
}


/// Adding prepared statement capabilities

// MARK: - Prepared Statements (SQL Injection Prevention)

extension MySQLClient {
    
    /// Die öffentliche Hauptmethode zum sicheren Ausführen einer SQL-Anfrage.
    public func execute(_ sqlTemplate: String, _ bindings: [Any] = []) -> [[String: Any]]? {
        // Sequenz-ID für jeden neuen Befehl zurücksetzen.
        self.sequenceId = 0
        
        // PHASE 1: Anweisung beim Server vorbereiten
        guard let statement = prepare(sql: sqlTemplate) else {
            print("❌ Vorbereiten des Statements fehlgeschlagen.")
            return nil
        }
        
        guard statement.paramCount == bindings.count else {
            print("❌ Fehler: Falsche Anzahl an Bindings. Erwartet: \(statement.paramCount), bekommen: \(bindings.count)")
            return nil
        }
        
        // PHASE 2: Vorbereitete Anweisung mit den Werten ausführen
        return executeStatement(statement, bindings: bindings)
    }
    
    // MARK: - Phase 1: PREPARE
    
    /// Sendet COM_STMT_PREPARE, parst die Metadaten und gibt sie zurück.
    private func prepare(sql: String) -> PreparedStatement? {
        print("➡️ Phase 1: Sende PREPARE für '\(sql)'")
        
        let payload = [0x16] + Array(sql.utf8) // COM_STMT_PREPARE
        guard sendPacket(payload: payload) else { return nil }
        
        // **THE FIX IS HERE**
        // 1. Lese das Paket zuerst.
        guard let (response, _) = readPacket() else {
            print("❌ Fehler beim Lesen der PREPARE-Antwort.")
            return nil
        }
        
        // 2. Prüfe jetzt den Inhalt des Pakets. `response` ist nun im ganzen Scope verfügbar.
        guard response.first == 0x00 else {
            print("❌ Keine PREPARE_OK Antwort erhalten.")
            decodeMySQLError(response) // Jetzt funktioniert dieser Aufruf
            return nil
        }
        
        // Der Rest der Funktion bleibt gleich...
        let statementId = response.toInteger(from: 1, length: 4) as UInt32
        let columnCount = response.toInteger(from: 5, length: 2) as UInt16
        let paramCount = response.toInteger(from: 7, length: 2) as UInt16
        
        if paramCount > 0 {
            for _ in 0..<paramCount { _ = readPacket() }
            _ = readPacket() // EOF
        }
        
        var columnNames: [String] = []
        if columnCount > 0 {
            for _ in 0..<columnCount {
                guard let (colDef, _) = readPacket() else { return nil }
                var defOffset = 0
                _ = readLengthEncodedString(from: colDef, at: &defOffset)
                _ = readLengthEncodedString(from: colDef, at: &defOffset)
                _ = readLengthEncodedString(from: colDef, at: &defOffset)
                _ = readLengthEncodedString(from: colDef, at: &defOffset)
                if let name = readLengthEncodedString(from: colDef, at: &defOffset) {
                    columnNames.append(name)
                }
            }
            _ = readPacket() // EOF
        }
        
        print("... PREPARE OK. Statement-ID: \(statementId), Spalten: \(columnCount), Parameter: \(paramCount)")
        return PreparedStatement(statementId: statementId, columnCount: columnCount, paramCount: paramCount, columnNames: columnNames)
    }
    
    // MARK: - Phase 2: EXECUTE
    
    /// Sendet COM_STMT_EXECUTE mit den gebundenen Werten und parst das binäre Ergebnis.
    private func executeStatement(_ statement: PreparedStatement, bindings: [Any]) -> [[String: Any]]? {
        print("➡️ Phase 2: Sende EXECUTE für Statement \(statement.statementId)")
        
        // WICHTIG: Sequenz für einen neuen Befehl zurücksetzen!
        self.sequenceId = 0
        
        let payload = buildExecutePacket(statement: statement, bindings: bindings)
        guard sendPacket(payload: payload) else { return nil }
        
        // --- ANTWORT KORREKT VERARBEITEN ---
        
        // 1. Das erste Paket lesen. Dies ist die Spaltenanzahl.
        guard let (columnCountPacket, _) = readPacket() else { return nil }
        
        // Prüfen, ob es ein Fehler- oder OK-Paket war.
        if columnCountPacket.first == 0xFF {
            decodeMySQLError(columnCountPacket); return nil
        }
        if columnCountPacket.first == 0x00 {
            print("... EXECUTE ergab ein OK-Paket (keine Datenzeilen).")
            return []
        }
        
        // Spaltenanzahl aus dem ersten Paket lesen.
        let columnCount = Int(columnCountPacket[0])
        guard columnCount == statement.columnCount else {
            print("❌ Diskrepanz bei Spaltenanzahl zwischen PREPARE und EXECUTE.")
            return nil
        }
        
        // 2. Die (redundanten) Spaltendefinitionen lesen und ignorieren.
        for _ in 0..<columnCount {
            _ = readPacket()
        }
        
        // 3. Das EOF-Paket nach den Spaltendefinitionen lesen.
        _ = readPacket()
        
        // 4. Jetzt die eigentlichen Datenzeilen lesen.
        var allRows: [[String: Any]] = []
        while true {
            guard let (rowPacket, _) = readPacket() else { break }
            
            // Prüfe auf das finale EOF-Paket
            if rowPacket.first == 0xFE && rowPacket.count < 9 { break }
            
            var rowOffset = 1 // Überspringe das 0x00 Paket-Präfix der Binär-Zeile
            rowOffset += Int((statement.columnCount + 7) / 8) // Überspringe die NULL-Bitmap
            
            var currentRow: [String: Any] = [:]
            for i in 0..<statement.columnCount {
                let colName = statement.columnNames[Int(i)]
                if let value = readLengthEncodedString(from: rowPacket, at: &rowOffset) {
                    currentRow[colName] = value
                }
            }
            allRows.append(currentRow)
        }
        
        print("... EXECUTE OK. \(allRows.count) Zeilen empfangen.")
        return allRows
    }
    
    // MARK: - Helfer für Packet-Building & Parsing
    
    private func buildExecutePacket(statement: PreparedStatement, bindings: [Any]) -> [UInt8] {
        var payload = [UInt8]()
        payload.append(0x17) // COM_STMT_EXECUTE
        payload += statement.statementId.littleEndianBytes
        payload.append(0x00) // Flags: CURSOR_TYPE_NO_CURSOR
        payload += [0x01, 0x00, 0x00, 0x00] // Iteration count
        
        if !bindings.isEmpty {
            payload += [UInt8](repeating: 0, count: Int((statement.paramCount + 7) / 8)) // NULL-Bitmap
            payload.append(0x01) // new-params-bind-flag
            
            var typesPayload: [UInt8] = []
            var valuesPayload: [UInt8] = []
            
            for binding in bindings {
                switch binding {
                case let str as String:
                    typesPayload += [0xFD, 0x00] // Typ: VARCHAR
                    valuesPayload += str.asLengthEncodedString
                case let num as Int:
                    typesPayload += [0x08, 0x00] // Typ: LONGLONG
                    valuesPayload += Int64(num).littleEndianBytes
                default:
                    typesPayload += [0x06, 0x00] // Typ: NULL
                }
            }
            payload += typesPayload
            payload += valuesPayload
        }
        return payload
    }
    
    private func readLengthEncodedString(from payload: [UInt8], at offset: inout Int) -> String? {
        // Liest die erwartete Länge und wie viele Bytes die Längenangabe selbst belegt.
        guard let (length, lenBytes) = payload.readLengthEncodedInteger(at: offset) else { return nil }
        offset += lenBytes
        
        // NEU: Prüfen, ob genügend Daten im Paket für den String vorhanden sind.
        // Dies verhindert den Absturz.
        guard offset + Int(length) <= payload.count else {
            print("❌ Parser-Fehler: Erwartete Länge (\(length)) überschreitet Paketgröße.")
            return nil
        }
        
        // Dieser Zugriff ist jetzt sicher.
        let data = payload[offset..<(offset + Int(length))]
        offset += Int(length)
        
        return String(bytes: data, encoding: .utf8)
    }
}


// MARK: - Low-Level Packet I/O

private extension MySQLClient {
    
    /// Sendet einen Payload als MySQL-Paket mit korrektem Header und aktueller Sequenz-ID.
    /// - Parameter payload: Die zu sendenden Daten.
    /// - Returns: `true` bei Erfolg, `false` bei einem Fehler.
    @discardableResult
    func sendPacket(payload: [UInt8]) -> Bool {
        let length = UInt32(payload.count)
        let header: [UInt8] = [
            UInt8(length & 0xFF),
            UInt8((length >> 8) & 0xFF),
            UInt8((length >> 16) & 0xFF),
            self.sequenceId // Nutzt die aktuelle Sequenz-ID
        ]
        
        let fullPacket = header + payload
        guard send(socket, fullPacket, fullPacket.count, 0) == fullPacket.count else {
            perror("❌ Senden des Pakets fehlgeschlagen")
            return false
        }
        
        // Zähle die Sequenz-ID für das nächste Paket hoch.
        self.sequenceId += 1
        return true
    }
    
}
