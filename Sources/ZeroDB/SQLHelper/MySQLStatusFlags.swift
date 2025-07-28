//
//  MySQLStatusFlags.swift
//  ZEMI
//
//  Created by Philipp Kotte on 19.07.25.
//


import Foundation

/// Repräsentiert die Server-Status-Flags, die im MySQL/MariaDB-Protokoll
/// gesendet werden, um den aktuellen Zustand der Verbindung zu beschreiben.
struct MySQLStatusFlags: OptionSet {
    public let rawValue: UInt16

    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }

    /// Der Server befindet sich innerhalb einer Transaktion.
    static let inTransaction              = MySQLStatusFlags(rawValue: 1 << 0)
    
    /// Der Server ist im Autocommit-Modus.
    static let autocommit                 = MySQLStatusFlags(rawValue: 1 << 1)
    
    /// Es gibt weitere Ergebnisse nach dem aktuellen Set.
    static let moreResultsExists          = MySQLStatusFlags(rawValue: 1 << 3)
    
    /// Die Abfrage hat keinen guten Index verwendet.
    static let queryNoGoodIndexUsed       = MySQLStatusFlags(rawValue: 1 << 4)
    
    /// Die Abfrage hat überhaupt keinen Index verwendet.
    static let queryNoIndexUsed           = MySQLStatusFlags(rawValue: 1 << 5)
    
    /// Ein Cursor existiert auf dem Server.
    static let cursorExists               = MySQLStatusFlags(rawValue: 1 << 6)
    
    /// Die letzte Zeile des Cursors wurde gesendet.
    static let lastRowSent                = MySQLStatusFlags(rawValue: 1 << 7)
    
    /// Der Sitzungszustand hat sich geändert.
    static let sessionStateChanged        = MySQLStatusFlags(rawValue: 1 << 13)
}
