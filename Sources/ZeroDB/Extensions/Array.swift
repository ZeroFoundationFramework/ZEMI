//
//  Array.swift
//  ZEMI
//
//  Created by Philipp Kotte on 28.07.25.
//

import Foundation

public extension Array where Element == UInt8 {
    func toInteger<T: FixedWidthInteger>(from index: Int, length: Int) -> T {
        return Data(self[index..<(index+length)]).withUnsafeBytes { $0.load(as: T.self) }.littleEndian
    }
    
    func readLengthEncodedInteger(at offset: Int) -> (value: UInt64, length: Int)? {
        guard offset < self.count else { return nil }
        let firstByte = self[offset]
        switch firstByte {
        case 0...0xFA: return (UInt64(firstByte), 1)
        case 0xFC: return (UInt64(self.toInteger(from: offset + 1, length: 2) as UInt16), 3)
        case 0xFD: return (UInt64(self.toInteger(from: offset + 1, length: 3) as UInt32), 4) // Korrigiert für 3-byte
        case 0xFE: return (self.toInteger(from: offset + 1, length: 8) as UInt64, 9)
        default: return nil
        }
    }
}
