//
//  Int.swift
//  ZEMI
//
//  Created by Philipp Kotte on 28.07.25.
//

extension Int{
    
    public static func bytesToInt(from byteArray: [UInt8], bigEndian: Bool) -> Int {
        var result: Int = 0
        
        // Wähle die Reihenfolge der Bytes basierend auf der Endianness
        let bytes = bigEndian ? byteArray : byteArray.reversed()
        
        for byte in bytes {
            // 1. Schiebe das bisherige Ergebnis um 8 Bits nach links,
            //    um Platz für das nächste Byte zu machen.
            result = result << 8
            
            // 2. Füge das neue Byte mit einer bitweisen ODER-Operation hinzu.
            result = result | Int(byte)
        }
        
        return result
    }
}
