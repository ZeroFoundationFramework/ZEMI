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
    
    public func getProtocolVersionFromHandshake(){
        self.protocolVersion = DBClientProtocolVersion(rawValue: Int(self.buffer[self.currentOffset])) ?? .v_unknown
        print("Protocol Version: \(self.protocolVersion)")
        self.currentOffset += 1
    }
    
    /// Parses the human-readable server version string from the initial handshake packet.
    ///
    /// This function scans the internal `buffer` starting from the `currentOffset` for a null terminator (`0x00`).
    /// The bytes between the current offset and the terminator are then decoded as a UTF-8 string,
    /// which typically contains version information like "11.7.2-MariaDB".
    ///
    /// Upon successful parsing, the function prints the server version to the console and advances the
    /// `currentOffset` to the position immediately following the null terminator, preparing the buffer
    /// for subsequent parsing operations.
    ///
    /// - Throws: `DBClientErrors.serverVersionNotFound` if a null terminator cannot be found within
    ///   the remaining portion of the buffer, which suggests a malformed or incomplete packet.
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
    
    /// Parses the ConnectionId as an Int from the initial handshake packet.
    ///
    /// This function reads the internal buffer from the latest offset  build by ``getServerVersionFromHandshake()``
    /// for the next `4 Bytes` to dertermine the connectionId. The connectionId is a running number and will increase by one per connection made.
    public func getConectionIdFromHandshake() {
        
        
        do{
            
            let data = try extraxt(length: 4)
            let conId = Int.bytesToInt(from: data, bigEndian: false)
            print("Connection Id: \(conId)")
        }catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    /// Parses the first part of the authentication salt from the handshake buffer.
    ///
    /// In the MySQL/MariaDB handshake protocol, the full authentication salt is sent in two parts.
    /// This function handles the first part, which is always 8 bytes long. It calls the
    /// ``extraxt(length:)`` method to read the data from the internal buffer and appends
    /// the resulting bytes to the instance's `salt` property.
    ///
    /// Any errors thrown by the underlying ``extraxt(length:)`` call are caught
    /// internally and printed to the console as a localized description.
    public func getFirstSaltFromHandshake() {
        
        do{
            let data = try extraxt(length: 8)
            self.salt += data
            print("Salt empfangen \(self.salt)")
        }catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    /// Advances the buffer's current offset by a given number of bytes.
    ///
    /// This is a utility function used to skip over reserved or unneeded sections
    /// of the handshake packet during the parsing process. It directly adds the
    /// value of the `over` parameter to the instance's `currentOffset` property.
    ///
    /// - Parameter over: The number of bytes to skip in the buffer.
    public func jump(over: Int){
        self.currentOffset += over
    }
    
    /// Parses the lower 16 bits of the server's capability flags from the handshake buffer.
    ///
    /// The full 32-bit capability mask is split into two parts in the handshake packet.
    /// This function reads the first 2-byte, little-endian integer and stores it in the
    /// `lowerCapabilities` property. It will later be combined with the upper 16 bits to form
    /// the complete set of server capabilities.
    ///
    /// This function catches any errors from the underlying ``extraxt(length:)`` call
    /// and prints them to the console.
    public func getLowerCapabilitiesFromHandshake() {
        
        do{
            let data = try extraxt(length: 2)
            self.lowerCapabilities = UInt16(Int.bytesToInt(from: data, bigEndian: false))
        }catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    /// Parses the server's default character set from the handshake buffer.
    ///
    /// This function reads a single byte from the buffer which represents the default
    /// character set ID for the connection (e.g., `45` for `utf8mb4_general_ci`).
    /// It then attempts to map this ID to a known `MySQLCharacterSet` enum case
    /// and prints a descriptive name for the detected character set.
    ///
    /// Any errors thrown by the underlying ``extraxt(length:)`` call are caught
    /// and printed to the console.
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
    
    /// Parses the 2-byte server status flags from the initial handshake packet.
    ///
    /// This function reads a 2-byte little-endian integer from the buffer, which represents a
    /// bitmask of the server's status at the time of connection. It decodes this bitmask
    /// into a `MySQLStatusFlags` OptionSet to provide information about the server's state,
    /// such as its transaction status or autocommit mode.
    ///
    /// For debugging purposes, the function prints a confirmation message to the console if
    /// specific, well-known flags like `.autocommit` or `.inTransaction` are detected.
    /// Any errors from the underlying ``extraxt(length:)`` call are caught and printed locally.
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
    
    /// Parses the upper 16 bits of the server's capability flags and constructs the complete 32-bit capability set.
    ///
    /// This function reads the final 2 bytes of the capability field from the handshake packet. It then
    /// combines this upper portion with the previously parsed ``lowerCapabilities`` property by bit-shifting
    /// the upper value 16 bits to the left and performing a bitwise OR.
    ///
    /// The resulting 32-bit integer is used to initialize the final `serverCapabilities` property
    /// with the complete set of flags supported by the server. Any errors during the extraction process
    /// are caught and printed to the console.
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
    
    /// Parses the length of the authentication plugin data from the handshake buffer.
    ///
    /// This function is called when the server supports pluggable authentication (`CLIENT_PLUGIN_AUTH`).
    /// It reads a single byte from the buffer that specifies the combined length of the
    /// authentication salt. This value can then be used to determine how many bytes to read
    /// for the second part of the salt.
    ///
    /// If an error occurs while reading from the buffer, it is printed to the console, and the
    /// function will return its initial value of `0`.
    ///
    /// - Returns: The length of the authentication plugin data as an integer, or `0` if an error was encountered.
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
    
    /// Parses the second part of the authentication salt from the handshake buffer.
    ///
    /// This function is responsible for reading the final, variable-length portion of the authentication salt.
    /// It calculates the exact number of bytes to read based on the total `length` of the
    /// authentication plugin data field, accounting for the 8 bytes of the salt that were previously read.
    ///
    /// The resulting bytes are then appended to the instance's `salt` property to form the complete
    /// salt required for password scrambling. Any errors during the extraction are caught and printed to the console.
    ///
    /// - Parameter length: The total length of the authentication plugin data field from the handshake.
    public func getSecondSaltFromHandshake(length: Int) {
        
        do{
            
            let data = try extraxt(length: max(13, length - 8))
            self.salt += data
        }catch let error {
            print(error.localizedDescription)
        }
    }
    
    /// Parses the name of the authentication plugin requested by the server.
    ///
    /// This function is called during the handshake if the server supports pluggable authentication
    /// (indicated by the `CLIENT_PLUGIN_AUTH` capability). It reads the null-terminated string
    /// from the buffer which specifies the authentication method the client must use for the login
    /// response (e.g., "caching_sha2_password" or "mysql_native_password").
    ///
    /// The parsed name is stored in the `authPluginName` property for use during the login process.
    /// It also advances the `currentOffset` past the parsed string.
    ///
    /// - Throws: `DBClientErrors.authPluginNameNotFound` if a null terminator cannot be found,
    ///   indicating a malformed packet.
    public func getAuthPluginNameFromHandshake() throws {
        // Find the end of the null-terminated string.
        guard let nullIndex = self.buffer[self.currentOffset...].firstIndex(of: 0) else {
            print("❌ Auth-Plugin-Name nicht gefunden")
            throw DBClientErrors.authPluginNameNotFound
        }
        
        // Extract the bytes and decode them.
        let pluginNameBytes = self.buffer[self.currentOffset..<nullIndex]
        if let pluginName = String(bytes: pluginNameBytes, encoding: .utf8), !pluginName.isEmpty {
            // Store the name for later use in the login function.
            self.authPluginName = pluginName
            print("🔑 Server verlangt Authentifizierung mit: \(self.authPluginName)")
        }
        
        // Advance the offset past the string and its null terminator.
        self.currentOffset = nullIndex + 1
    }
}
