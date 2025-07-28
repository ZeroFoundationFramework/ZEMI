import Foundation

/// Repräsentiert die Server-Status-Flags, die im MySQL/MariaDB-Protokoll
/// gesendet werden, um den aktuellen Zustand der Verbindung zu beschreiben.
public struct MySQLStatusFlags: OptionSet {
    public let rawValue: UInt16

    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }

    /// Der Server befindet sich innerhalb einer Transaktion.
    public static let inTransaction              = MySQLStatusFlags(rawValue: 1 << 0)
    
    /// Der Server ist im Autocommit-Modus.
    public static let autocommit                 = MySQLStatusFlags(rawValue: 1 << 1)
    
    /// Es gibt weitere Ergebnisse nach dem aktuellen Set.
    public static let moreResultsExists          = MySQLStatusFlags(rawValue: 1 << 3)
    
    /// Die Abfrage hat keinen guten Index verwendet.
    public static let queryNoGoodIndexUsed       = MySQLStatusFlags(rawValue: 1 << 4)
    
    /// Die Abfrage hat überhaupt keinen Index verwendet.
    public static let queryNoIndexUsed           = MySQLStatusFlags(rawValue: 1 << 5)
    
    /// Ein Cursor existiert auf dem Server.
    public static let cursorExists               = MySQLStatusFlags(rawValue: 1 << 6)
    
    /// Die letzte Zeile des Cursors wurde gesendet.
    public static let lastRowSent                = MySQLStatusFlags(rawValue: 1 << 7)
    
    /// Der Sitzungszustand hat sich geändert.
    public static let sessionStateChanged        = MySQLStatusFlags(rawValue: 1 << 13)
}
