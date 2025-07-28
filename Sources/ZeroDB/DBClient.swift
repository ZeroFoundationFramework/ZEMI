//
//  DBClient.swift
//  ZEMI
//
//  Created by Philipp Kotte on 28.07.25.
//

import Foundation

public class DBClient {
    
    public var socket: Int32 = -1
    public var salt: [UInt8] = []
    
    public var sequenceId: UInt8 = 0
    
    public var host: String
    public var port: UInt16
    public var currentOffset = 4
    
    public var lowerCapabilities: UInt16 = 0
    public var upperCapabilities: UInt16 = 0
    public var serverCapabilites: DBClientCapability = []
    
    public var buffer: [UInt8] = [UInt8](repeating: 0, count: 512)
    
    private var capabilities: [DBClientCapability] = []
    
    public var protocolVersion: DBClientProtocolVersion = .v_unknown
    
    public var authPluginName: String = ""
    
    
    init?(host: String = "127.0.0.1", port: UInt16 = 3306) {
        self.host = host
        self.port = port
        guard setup_socket() else { return nil }
        guard connect_and_handshake() else {
            close(self.socket) // Wichtig: Socket vor dem Verlassen aufräumen
            return nil
        }
    }
    
    private func setup_socket() -> Bool { // ÄNDERUNG: Gibt Bool zurück
        let sock = Darwin.socket(AF_INET, SOCK_STREAM, 0)
        guard sock >= 0 else {
            perror("❌ Socket-Erstellung fehlgeschlagen")
            return false
        }
        self.socket = sock
        return true
    }
    
    private func connect_and_handshake() -> Bool { // ÄNDERUNG: Gibt Bool zurück
        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = self.port.bigEndian
        inet_pton(AF_INET, host, &addr.sin_addr)
        
        let result = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { pointer in
                connect(self.socket, pointer, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        
        guard result == 0 else {
            perror("Verbindung fehlgeschlagen")
            return false
        }
        
        print("Verbunden mit DB-Server bei \(host):\(port)")
        
        // Jetzt den Handshake versuchen. Wenn er einen Fehler wirft, fangen wir ihn
        // und geben false zurück, um den init fehlschlagen zu lassen.
        do {
            try readHandshakePacket()
            return true
        } catch {
            print("Handshake fehlgeschlagen: \(error)")
            return false
        }
    }
    
    public func connect_internally(){
        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = self.port.bigEndian
        inet_pton(AF_INET, host, &addr.sin_addr)
        
        
        let result = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { pointer in
                connect(self.socket, pointer, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        
        guard result == 0 else {
            perror("Verbdinung fehlgeschlagen")
            return
        }
        
        print("Verbunden mit DB-Server bei \(host):\(port)")
        do{
            try readHandshakePacket()
        } catch DBClientErrors.serverVersionNotFound{
            print("Server faild sending the Server version or packet was malformed")
        } catch DBClientErrors.connectionIdNotFound {
            print("Server faild sending Connection Id or packet was malformed")
        } catch {
            print("An unexpected Error occured: \(error)")
        }
        
    }
    
    
    private func readHandshakePacket() throws {
        let bytesRead = recv(self.socket, &self.buffer, buffer.count, 0)
        
        guard bytesRead > 0 else {
            perror("Es wurde kein Handshake empfangfen")
            return
        }
        
        print("📥 Handshake empfangen: \(bytesRead) Bytes")
        
        // 1. protocol version
        getProtocolVersionFromHandshake()
        
        // 2. Server version
        try getServerVersionFromHandshake()
        
        // 3. connectionId
        getConectionIdFromHandshake()
        
        // 4. salt part 1
        getFirstSaltFromHandshake()
        
        // 5. reserved bit
        jump(over: 1)
        
        // 6. capabilities lower half
        getLowerCapabilitiesFromHandshake()
        
        // 7. CharacterSet
        getCharacterSetFromHandshake()
        
        //8. StatusFlag
        getStatusFlagsFromHandshake()
        
        //9. capabilities upper half
        getUpperCapabilitiesFromHandshake()
        
        self.capabilities.forEach { print($0.description) }
        
        
        var auth_plugin_data_len = 0
        
        // 9. auth plugin data length
        if(self.serverCapabilites.contains(.client_plugin_auth)){
            auth_plugin_data_len = getAuthPluginDataLengthFromHandshake()
        }else{
            jump(over: 1)
        }
        
        jump(over: 10)
        
        getSecondSaltFromHandshake(length: auth_plugin_data_len)
        
        try getAuthPluginNameFromHandshake()
        
    }
    
    public func login(username: String, password: String, database: String) {
        
        let payload = SQLClientHelper.buildPayload(
            username,
            password,
            self.salt,
            serverCapabilities: self.serverCapabilites,
            database: database
        )
        
        let header = SQLClientHelper.buildHeader(length: UInt32(payload.count))
        
        let fullPacket = header + payload
        let sent = send(self.socket, fullPacket, fullPacket.count, 0)
        if sent < 0 {
            perror("❌ Login-Paket senden fehlgeschlagen")
            
        }
        
        print("📤 Login-Paket gesendet")
        
        var response = [UInt8](repeating: 0, count: 1024)
        let received = recv(self.socket, &response, response.count, 0)
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
            return
        }
        return
    }
    
}
