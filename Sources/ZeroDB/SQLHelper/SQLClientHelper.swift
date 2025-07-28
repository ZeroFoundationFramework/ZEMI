//
//  SQLClientHelper.swift
//  ZEMI
//
//  Created by Philipp Kotte on 16.07.25.
//
import Foundation
import CryptoKit

final class SQLClientHelper {
    
    public static func buildHeader(length: UInt32) -> [UInt8] {
        
        return [ UInt8(length & 0xFF), UInt8((length >> 8) & 0xFF), UInt8((length >> 16) & 0xFF), 1]
    }
    
    public static func buildPayload(_ username: String, _ password: String, _ salt: [UInt8], serverCapabilities: DBClientCapability, database: String? = nil) -> [UInt8]{
        
        let token = scramble(password: password, salt: salt)
        
        var clientFlags: DBClientCapability = [
            .client_protocol_41,
            .client_plugin_auth,
            .client_secure_connection,
            
        ]
        
        if(database != nil){
            clientFlags.insert(.client_connect_with_db)
        }
        
        let finalCapabilities = serverCapabilities.intersection(clientFlags)
        
        let charset: UInt8 = 0x45 // utf8_general_ci
        
        
        var payload = [UInt8]()
        payload += withUnsafeBytes(of: finalCapabilities.rawValue.littleEndian, Array.init)
        payload += [0, 0, 0, 0] // max packet size
        payload.append(charset)
        payload += [UInt8](repeating: 0, count: 23)
        payload += Array(username.utf8) + [0]
        payload.append(UInt8(token.count))
        payload += token
        
        // --- KORREKTUR HIER ---
        // Check the NEGOTIATED capabilities, not just if the database string exists.
        if finalCapabilities.contains(.client_connect_with_db) {
            if let db = database {
                payload += Array(db.utf8) + [0]
            }
        }
        
        // Send the auth plugin name only if negotiated
        if finalCapabilities.contains(.client_plugin_auth) {
            payload += Array("mysql_native_password".utf8) + [0]
        }
        
        return payload
    }
    
    /// Creates a password hash using the `mysql_native_password` algorithm.
    ///
    /// This algorithm is defined as: `SHA1(password) XOR SHA1(salt + SHA1(SHA1(password)))`
    ///
    /// - Parameters:
    ///   - password: The user's password string.
    ///   - salt: The 20-byte salt received from the server during the handshake.
    /// - Returns: A 20-byte array representing the hashed password.
    public static func scramble(password: String, salt: [UInt8]) -> [UInt8] {
        guard !password.isEmpty, salt.count >= 20 else { return [] }

        // 1. Erzeuge SHA1(password)
        // Dieses Ergebnis wird für das finale XORing benötigt.
        let pass_hash = Insecure.SHA1.hash(data: Data(password.utf8))

        // 2. Erzeuge SHA1(SHA1(password))
        let pass_hash2 = Insecure.SHA1.hash(data: Data(pass_hash))
        
        // 3. Kombiniere den Salt mit dem ZWEITEN Hash
        // salt + SHA1(SHA1(password))
        var salt_and_pass_hash2 = Data(salt.prefix(20))
        salt_and_pass_hash2.append(contentsOf: pass_hash2)

        // 4. Hashe diese Kombination
        // SHA1(salt + SHA1(SHA1(password)))
        let reply_hash = Insecure.SHA1.hash(data: salt_and_pass_hash2)
        
        // 5. Führe die finale XOR-Operation durch:
        // SHA1(password) XOR SHA1(salt + SHA1(SHA1(password)))
        let final_token_bytes = zip(pass_hash, reply_hash).map { $0 ^ $1 }
        
        return Array(final_token_bytes)
    }
}


