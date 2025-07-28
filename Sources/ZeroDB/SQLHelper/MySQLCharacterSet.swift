//
//  MySQLCharacterSet.swift
//  ZEMI
//
//  Created by Philipp Kotte on 19.07.25.
//


import Foundation

/// Repräsentiert die Character Set ID, die vom MySQL/MariaDB-Server
/// im Handshake-Paket gesendet wird.
public enum MySQLCharacterSet: UInt8 {
    // MARK: - Gängige Zeichensätze
    case big5_chinese_ci = 1
    case latin1_swedish_ci = 8
    case latin2_general_ci = 9
    case utf8mb3_general_ci = 33 // Veraltet, oft als 'utf8' bezeichnet
    case utf8mb4_general_ci = 45
    case utf8mb4_unicode_ci = 224
    case binary = 63

    // MARK: - Spezifische Zeichensätze aus deinen Logs
    case latin1_danish_ci = 15
    case cp850_general_ci = 4
    case hp8_english_ci = 6
    case koi8r_general_ci = 7
    
    // Dein Fall mit ID 54
    case cp932_japanese_ci = 54
    
    // Weitere aus deinen Logs
    case geostd8_general_ci = 92
    case cp932_bin = 95 // Dein Fall mit ID 95
    case euckr_korean_ci = 19
    
    // Einige IDs aus deinen Logs (52, 56) sind oft Kollationen
    // von komplexeren Zeichensätzen wie `latin5` oder `cp1250`.
    // Hier sind die häufigsten als Referenz:
    case latin5_turkish_ci = 30
    case cp1250_general_ci = 26
    case cp1251_general_ci = 14
    
    /// Gibt eine menschenlesbare Beschreibung des Zeichensatzes zurück.
    public var description: String {
        switch self {
        case .utf8mb4_general_ci, .utf8mb4_unicode_ci:
            return "utf8mb4 (Unicode, unterstützt Emojis)"
        case .utf8mb3_general_ci:
            return "utf8 (veraltet, Unicode, max. 3 Bytes)"
        case .latin1_swedish_ci:
            return "latin1 (Westeuropäisch)"
        case .binary:
            return "binary (reine Binärdaten, keine Zeicheninterpretation)"
        case .cp932_japanese_ci, .cp932_bin:
            return "cp932 (Shift-JIS für Japanisch)"
        default:
            return "Spezifischer Zeichensatz (ID: \(self.rawValue))"
        }
    }
}

/*
 =================================================================
  ANWENDUNGSBEISPIEL:
 =================================================================

 // Angenommen, du hast diese ID aus dem Handshake gelesen:
 let charsetIDFromServer: UInt8 = 54

 // Wandle die ID sicher in deine enum um
 if let charset = MySQLCharacterSet(rawValue: charsetIDFromServer) {
     print("Empfangener Zeichensatz: \(charset.description)")
     // Ausgabe: Empfangener Zeichensatz: cp932 (Shift-JIS für Japanisch)
 } else {
     print("Unbekannter Zeichensatz mit ID: \(charsetIDFromServer)")
 }

*/
