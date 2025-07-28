//
//  FixedWithInteger.swift
//  ZEMI
//
//  Created by Philipp Kotte on 28.07.25.
//


public extension FixedWidthInteger {
    var littleEndianBytes: [UInt8] {
        withUnsafeBytes(of: self.littleEndian) { Array($0) }
    }
}
