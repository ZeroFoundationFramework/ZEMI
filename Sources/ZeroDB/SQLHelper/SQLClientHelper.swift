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
    
    public static func buildPayload(_ username: String, _ password: String, _ salt: [UInt8], database: String? = nil) -> [UInt8]{
        
        let token = scramble(password: password, salt: salt)
        
        let CLIENT_PROTOCOL_41: UInt32 = 0x00000200
        let CLIENT_SECURE_CONNECTION: UInt32 = 0x00008000
        let CLIENT_PLUGIN_AUTH: UInt32 = 0x00080000
        let CLIENT_LONG_PASSWORD: UInt32 = 0x00000001
        let CLIENT_CONNECT_WITH_DB: UInt32 = 0x00000008
        
        var capabilities: UInt32 = 0
        
        if(database == nil){
            capabilities =
                CLIENT_LONG_PASSWORD |
                CLIENT_PROTOCOL_41 |
                CLIENT_SECURE_CONNECTION |
                CLIENT_PLUGIN_AUTH
        }else{
            capabilities =
            CLIENT_LONG_PASSWORD |
            CLIENT_PROTOCOL_41 |
            CLIENT_SECURE_CONNECTION |
            CLIENT_PLUGIN_AUTH |
            CLIENT_CONNECT_WITH_DB
        }

        let charset: UInt8 = 0x21 // utf8_general_ci
        
        
        var payload = [UInt8]()
        payload += withUnsafeBytes(of: capabilities.littleEndian, Array.init)
        payload += [0, 0, 0, 0] // max packet size
        payload.append(charset)
        payload += [UInt8](repeating: 0, count: 23)
        payload += Array(username.utf8) + [0]
        payload.append(UInt8(token.count))
        payload += token
        if let db = database {
            payload += Array(db.utf8) + [0]
        }
        payload += Array("mysql_native_password".utf8) + [0]
        
        return payload
    }
    
    public static func scramble(password: String, salt: [UInt8]) -> [UInt8] {
        guard salt.count >= 20 else {
            print("❌ Salt ist zu kurz")
            return []
        }

        let passwordData = Data(password.utf8)
        let hashed = Data(Insecure.SHA1.hash(data: passwordData))              // SHA1(password)
        let hashedAgain = Data(Insecure.SHA1.hash(data: hashed))               // SHA1(SHA1(password))

        var salted = Data(salt.prefix(20))                                     // 20-Byte Salt
        salted.append(hashedAgain)                                             // Salt + SHA1(SHA1(password))

        let final = Data(Insecure.SHA1.hash(data: salted))                     // SHA1(Salt + SHA1(SHA1(password)))

        let token = zip(final, hashed).map { $0 ^ $1 }                         // SHA1(password) XOR Ergebnis

        return token
    }
}


