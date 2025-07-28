//
//  DBClientCapability.swift
//  ZEMI
//
//  Created by Philipp Kotte on 19.07.25.
//


import Foundation

public struct DBClientCapability: OptionSet, Sendable {
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    /*
     16384 - client_reserved
     8192 - client_transactions
     64 - client_odbc
     32 - client_compress
     16 - client_no_schema
     8 - client_connect_with_db
     */
    
    static let allFlags : [DBClientCapability] = [
            .client_long_password,
            .client_found_rows,
            .client_long_flag,
            .client_connect_with_db,
            .client_no_schema,
            .client_compress,
            .client_odbc,
            .client_local_files,
            .client_ignroe_space,
            .client_protocol_41,
            .client_interactive,
            .client_ssl,
            .client_ignore_sigpipe,
            .client_transactions,
            .client_reserved,
            .client_secure_connection,
            .client_multi_statements,
            .client_multi_results,
            .client_ps_multi_results,
            .client_plugin_auth,
            .client_connect_attrs,
            .client_plugin_auth_lenenc_client_data,
            .client_can_handle_expired_passwords,
            .client_session_track,
            .client_deprecate_eof,
            .client_optional_resultset_metadta,
            .client_zstd_compression_algorithm,
            .client_query_attributes,
            .multi_factor_authentication,
            .client_capability_extension,
            .client_ssl_verify_server_cert,
            .client_remember_options
    ]
    
    func components() -> [DBClientCapability] {
            var result: [DBClientCapability] = []
            for flag in DBClientCapability.allFlags {
                // .contains() prüft, ob die Bits des Flags in `self` gesetzt sind.
                if self.contains(flag) {
                    result.append(flag)
                }
            }
            return result
        }

    // MARK: - Von dir aufgelistete Werte (0-15)
    static let client_long_password  = DBClientCapability(rawValue: 1)       // 1
    static let client_found_rows  = DBClientCapability(rawValue: 2)       // 2
    static let client_long_flag  = DBClientCapability(rawValue: 4)       // 4
    static let client_connect_with_db  = DBClientCapability(rawValue: 8)       // 8
    static let client_no_schema = DBClientCapability(rawValue: 16)      // 16
    static let client_compress  = DBClientCapability(rawValue: 32)      // 32
    static let client_odbc  = DBClientCapability(rawValue: 64)      // 64
    static let client_local_files  = DBClientCapability(rawValue: 128)     // 128
    static let client_ignroe_space  = DBClientCapability(rawValue: 256)     // 256
    static let client_protocol_41  = DBClientCapability(rawValue: 512)     // 512
    static let client_interactive = DBClientCapability(rawValue: 1024)    // 1024
    static let client_ssl = DBClientCapability(rawValue: 2048)    // 2048
    static let client_ignore_sigpipe = DBClientCapability(rawValue: 4096)    // 4096
    static let client_transactions = DBClientCapability(rawValue: 8192)    // 8192
    static let client_reserved = DBClientCapability(rawValue: 16384)   // 16384
    static let client_secure_connection = DBClientCapability(rawValue: 32768)   // 32768

    // MARK: - Bit-Shifts von 16 bis 31
    static let client_multi_statements = DBClientCapability(rawValue: 1 << 16) // 65,536
    static let client_multi_results = DBClientCapability(rawValue: 1 << 17) // 131,072
    static let client_ps_multi_results = DBClientCapability(rawValue: 1 << 18) // 262,144
    static let client_plugin_auth = DBClientCapability(rawValue: 1 << 19) // 524,288
    static let client_connect_attrs = DBClientCapability(rawValue: 1 << 20) // 1,048,576
    static let client_plugin_auth_lenenc_client_data = DBClientCapability(rawValue: 1 << 21) // 2,097,152
    static let client_can_handle_expired_passwords = DBClientCapability(rawValue: 1 << 22) // 4,194,304
    static let client_session_track = DBClientCapability(rawValue: 1 << 23) // 8,388,608
    static let client_deprecate_eof = DBClientCapability(rawValue: 1 << 24) // 16,777,216
    static let client_optional_resultset_metadta = DBClientCapability(rawValue: 1 << 25) // 33,554,432
    static let client_zstd_compression_algorithm = DBClientCapability(rawValue: 1 << 26) // 67,108,864
    static let client_query_attributes = DBClientCapability(rawValue: 1 << 27) // 134,217,728
    static let multi_factor_authentication = DBClientCapability(rawValue: 1 << 28) // 268,435,456
    static let client_capability_extension = DBClientCapability(rawValue: 1 << 29) // 536,870,912
    static let client_ssl_verify_server_cert = DBClientCapability(rawValue: 1 << 30) // 1,073,741,824
    static let client_remember_options = DBClientCapability(rawValue: 1 << 31) // 2,147,483,648
    
    var description: String {
           switch self {
           // MARK: - Lower Bits
           case .client_long_password: return "CLIENT_LONG_PASSWORD: Verwendet das alte Passwort-Authentifizierungsprotokoll."
           case .client_found_rows: return "CLIENT_FOUND_ROWS: Gibt die Anzahl der gefundenen Zeilen anstelle der betroffenen Zeilen zurück."
           case .client_long_flag: return "CLIENT_LONG_FLAG: Verwendet längere Flags im Protokoll."
           case .client_connect_with_db: return "CLIENT_CONNECT_WITH_DB: Eine Datenbank kann beim Verbindungsaufbau angegeben werden."
           case .client_no_schema: return "CLIENT_NO_SCHEMA: Verbietet die 'datenbank.tabelle.spalte'-Syntax."
           case .client_compress: return "CLIENT_COMPRESS: Verwendet das Komprimierungsprotokoll."
           case .client_odbc: return "CLIENT_ODBC: Der Client ist ein ODBC-Client."
           case .client_local_files: return "CLIENT_LOCAL_FILES: Kann `LOAD DATA LOCAL` verwenden."
           case .client_ignroe_space: return "CLIENT_IGNORE_SPACE: Ignoriert Leerzeichen vor '('. "
           case .client_protocol_41: return "CLIENT_PROTOCOL_41: Verwendet das 4.1-Protokoll."
           case .client_interactive: return "CLIENT_INTERACTIVE: Der Client ist interaktiv (wartet auf Timeout)."
           case .client_ssl: return "CLIENT_SSL: Verwendet SSL-Verschlüsselung."
           case .client_ignore_sigpipe: return "CLIENT_IGNORE_SIGPIPE: Löst bei Verbindungsfehlern kein SIGPIPE aus."
           case .client_transactions: return "CLIENT_TRANSACTIONS: Der Client versteht Transaktionen."
           case .client_reserved: return "CLIENT_RESERVED: Veraltetes Flag für die 4.1-Authentifizierung."
           case .client_secure_connection: return "SECURE_CONNECTION"

           // MARK: - Higher Bits
           case .client_multi_statements: return "CLIENT_MULTI_STATEMENTS: Kann mehrere Anweisungen auf einmal verarbeiten."
           case .client_multi_results: return "CLIENT_MULTI_RESULTS: Kann mehrere Ergebnismengen verarbeiten."
           case .client_ps_multi_results: return "CLIENT_PS_MULTI_RESULTS: Kann mehrere Ergebnismengen von Prepared Statements verarbeiten."
           case .client_plugin_auth: return "CLIENT_PLUGIN_AUTH: Unterstützt steckbare Authentifizierung."
           case .client_connect_attrs: return "CLIENT_CONNECT_ATTRS: Sendet Verbindungsattribute."
           case .client_plugin_auth_lenenc_client_data: return "CLIENT_PLUGIN_AUTH_LENENC_CLIENT_DATA: Unterstützt längenkodierte Authentifizierungsdaten."
           case .client_can_handle_expired_passwords: return "CLIENT_CAN_HANDLE_EXPIRED_PASSWORDS: Kann den Ablauf für abgelaufene Passwörter handhaben."
           case .client_session_track: return "CLIENT_SESSION_TRACK: Kann Änderungen des Sitzungszustands verfolgen."
           case .client_deprecate_eof: return "CLIENT_DEPRECATE_EOF: Veraltet das EOF-Paket."
           case .client_optional_resultset_metadta: return "CLIENT_OPTIONAL_RESULTSET_METADATA: Erwartet optionale Metadaten für Ergebnismengen."
           case .client_zstd_compression_algorithm: return "CLIENT_ZSTD_COMPRESSION_ALGORITHM: Unterstützt den zstd-Komprimierungsalgorithmus."
           case .client_query_attributes: return "CLIENT_QUERY_ATTRIBUTES: Kann Abfrageattribute senden."
           case .multi_factor_authentication: return "MULTI_FACTOR_AUTHENTICATION: Unterstützt Multi-Faktor-Authentifizierung."
           case .client_capability_extension: return "CLIENT_CAPABILITY_EXTENSION: Unterstützt die Fähigkeitserweiterung."
           case .client_ssl_verify_server_cert: return "CLIENT_SSL_VERIFY_SERVER_CERT: Überprüft das SSL-Zertifikat des Servers."
           case .client_remember_options: return "CLIENT_REMEMBER_OPTIONS: Merkt sich Optionen nach einem Verbindungsabbruch."
               
           default:
               // Dieser Fall wird ausgelöst, wenn mehrere Flags kombiniert sind
               // oder der Wert unbekannt ist.
               return "Kombinierte oder unbekannte Flags (Rohwert: \(rawValue))"
           }
       }
}
