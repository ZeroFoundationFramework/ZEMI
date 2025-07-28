//
//  String.swift
//  ZEMI
//
//  Created by Philipp Kotte on 28.07.25.
//

public extension String {
    var asLengthEncodedString: [UInt8] {
        let data = Array(self.utf8)
        let length = UInt64(data.count)
        return length.littleEndianBytes.first!.asLengthEncodedInteger + data
    }
}
