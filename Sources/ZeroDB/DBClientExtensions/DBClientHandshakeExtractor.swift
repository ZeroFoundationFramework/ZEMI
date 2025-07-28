//
//  DBClientHandshakeExtractor.swift
//  ZEMI
//
//  Created by Philipp Kotte on 28.07.25.
//

extension DBClient {
    
    public func extraxt(length: Int) throws -> [UInt8]{
        if(length == 0){
            throw DBClientErrors.lengthZero
        }
        
        let end_offset = self.currentOffset + length
        
        let data = Array(self.buffer[self.currentOffset..<end_offset])
        
        if(data.count < length){
            throw DBClientErrors.returningLengthZero
        }
        self.currentOffset += length
        return data
        
    }
    
    public func getAuthPluginDataName() throws {
        self.currentOffset += 2
        
        guard let nullIndex = self.buffer[self.currentOffset...].firstIndex(of: 0) else {
            print("❌ Server-Version nicht gefunden")
            throw DBClientErrors.serverVersionNotFound
        }
        
        let versionBytes = self.buffer[self.currentOffset..<nullIndex]
        if let serverVersion = String(bytes: versionBytes, encoding: .utf8) {
            print("🧠 Server-Version: \(serverVersion)")
        }
        
    }
    
    public func getProtocolVersionFromHandshake(){
        self.protocolVersion = DBClientProtocolVersion(rawValue: Int(self.buffer[self.currentOffset])) ?? .v_unknown
        print("Protocol Version: \(self.protocolVersion)")
        self.currentOffset += 1
    }
    
    public func getServerVersionFromHandshake() throws {
        
        
        guard let nullIndex = self.buffer[self.currentOffset...].firstIndex(of: 0) else {
            print("❌ Server-Version nicht gefunden")
            throw DBClientErrors.serverVersionNotFound
        }
        
        let versionBytes = self.buffer[self.currentOffset..<nullIndex]
        if let serverVersion = String(bytes: versionBytes, encoding: .utf8) {
            print("🧠 Server-Version: \(serverVersion)")
        }
        self.currentOffset = nullIndex + 1
    }
    
    public func getConectionIdFromHandshake() {
        
        
        do{
            
            let data = try extraxt(length: 4)
            let conId = Int.bytesToInt(from: data, bigEndian: false)
            print("Connection Id: \(conId)")
        }catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    public func getFirstSaltFromHandshake() {
        
        do{
            let data = try extraxt(length: 8)
            self.salt += data
            print("Salt empfangen \(self.salt)")
        }catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    public func jump(over: Int){
        self.currentOffset += over
    }
    
    public func getLowerCapabilitiesFromHandshake() {
        
        do{
            let data = try extraxt(length: 2)
            self.lowerCapabilities = UInt16(Int.bytesToInt(from: data, bigEndian: false))
        }catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    public func getCharacterSetFromHandshake(){
        
        
        
        do{
            let data = try extraxt(length: 1)
            if let charset = MySQLCharacterSet(rawValue: data[0]) {
                print("Empfangener Zeichensatz: \(charset.description)")
            } else {
                print("Unbekannter Zeichensatz mit")
            }
            
        }catch let error {
            print(error.localizedDescription)
        }
    }
    
    public func getStatusFlagsFromHandshake() {
        
        
        do{
            let data = try extraxt(length: 2)
            let rawStatus = UInt16(Int.bytesToInt(from: data, bigEndian: false))
            
            let statusFlags = MySQLStatusFlags(rawValue: rawStatus)
            
            // Optional: Gib die erkannten Flags aus
            if statusFlags.contains(.autocommit) {
                print("✅ Server ist im Autocommit-Modus.")
            }
            if statusFlags.contains(.inTransaction) {
                print("⚠️ Server ist bereits in einer Transaktion.")
            }
            
        }catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    // Liest die oberen 2 Bytes der Capabilities
    public func getUpperCapabilitiesFromHandshake() {
        
        do{
            let data = try extraxt(length: 2)
            let upper = UInt16(Int.bytesToInt(from: data, bigEndian: false))
            let cap_raw = UInt32(UInt32(upper) << 16 | UInt32(self.lowerCapabilities))
            let fullCapabilities = DBClientCapability(rawValue: cap_raw)
            self.serverCapabilites = fullCapabilities
        }catch let error {
            print(error.localizedDescription)
        }
    }
    
    public func getAuthPluginDataLengthFromHandshake() ->  Int {
        
        var length = 0
        
        do{
            let data = try extraxt(length: 1)
            length = Int.bytesToInt(from: data, bigEndian: false)
        }catch let error {
            print(error.localizedDescription)
        }
        
        return length
    }
    
    public func getSecondSaltFromHandshake(length: Int) {
        
        do{
            
            let data = try extraxt(length: max(13, length - 8) - 1)
            self.salt += data
        }catch let error {
            print(error.localizedDescription)
        }
    }
}
