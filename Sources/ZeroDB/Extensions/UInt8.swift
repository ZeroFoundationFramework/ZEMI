//
//  UInt8.swift
//  ZEMI
//
//  Created by Philipp Kotte on 28.07.25.
//


public extension UInt8 {
    var asLengthEncodedInteger: [UInt8] {
        // Vereinfachte Version für Längen < 251
        return [self]
    }
}
