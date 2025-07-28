//
//  DBClientCapability.swift
//  ZEMI
//
//  Created by Philipp Kotte on 19.07.25.
//


import Foundation

struct DBClientCapabilityValues: OptionSet {
    let rawValue: UInt32

    // MARK: - Von dir aufgelistete Werte (0-15)
    static let client_long_password  = DBClientCapabilityValues(rawValue: 1)       // 1
    static let client_found_rows  = DBClientCapabilityValues(rawValue: 2)       // 2
    static let client_long_flag  = DBClientCapabilityValues(rawValue: 4)       // 4
    static let client_connect_with_db  = DBClientCapabilityValues(rawValue: 8)       // 8
    static let client_no_schame = DBClientCapabilityValues(rawValue: 16)      // 16
    static let client_compress  = DBClientCapabilityValues(rawValue: 32)      // 32
    static let client_odbc  = DBClientCapabilityValues(rawValue: 64)      // 64
    static let client_local_files  = DBClientCapabilityValues(rawValue: 128)     // 128
    static let client_ignroe_space  = DBClientCapabilityValues(rawValue: 256)     // 256
    static let client_protocol_41  = DBClientCapabilityValues(rawValue: 512)     // 512
    static let client_interactive = DBClientCapabilityValues(rawValue: 1024)    // 1024
    static let client_ssl = DBClientCapabilityValues(rawValue: 2048)    // 2048
    static let client_ignore_sigpipe = DBClientCapabilityValues(rawValue: 4096)    // 4096
    static let client_transactions = DBClientCapabilityValues(rawValue: 8192)    // 8192
    static let client_reserved = DBClientCapabilityValues(rawValue: 16384)   // 16384
    static let client_reserved2 = DBClientCapabilityValues(rawValue: 32768)   // 32768

    // MARK: - Bit-Shifts von 16 bis 31
    static let client_multi_statements = DBClientCapabilityValues(rawValue: 1 << 16) // 65,536
    static let client_multi_results = DBClientCapabilityValues(rawValue: 1 << 17) // 131,072
    static let client_ps_multi_results = DBClientCapabilityValues(rawValue: 1 << 18) // 262,144
    static let cliet_plugin_auth = DBClientCapabilityValues(rawValue: 1 << 19) // 524,288
    static let client_connect_attrs = DBClientCapabilityValues(rawValue: 1 << 20) // 1,048,576
    static let client_plugin_auth_lenenc_client_data = DBClientCapabilityValues(rawValue: 1 << 21) // 2,097,152
    static let client_can_handle_expired_passwords = DBClientCapabilityValues(rawValue: 1 << 22) // 4,194,304
    static let client_session_track = DBClientCapabilityValues(rawValue: 1 << 23) // 8,388,608
    static let client_deprecate_eof = DBClientCapabilityValues(rawValue: 1 << 24) // 16,777,216
    static let client_optional_resultset_metadta = DBClientCapabilityValues(rawValue: 1 << 25) // 33,554,432
    static let client_zstd_compression_algorithm = DBClientCapabilityValues(rawValue: 1 << 26) // 67,108,864
    static let client_query_attributes = DBClientCapabilityValues(rawValue: 1 << 27) // 134,217,728
    static let multi_factor_authentication = DBClientCapabilityValues(rawValue: 1 << 28) // 268,435,456
    static let client_capability_extension = DBClientCapabilityValues(rawValue: 1 << 29) // 536,870,912
    static let client_ssl_verify_server_cert = DBClientCapabilityValues(rawValue: 1 << 30) // 1,073,741,824
    static let client_remember_options = DBClientCapabilityValues(rawValue: 1 << 31) // 2,147,483,648
}
