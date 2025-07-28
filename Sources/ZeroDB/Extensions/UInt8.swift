private extension UInt8 {
    var asLengthEncodedInteger: [UInt8] {
        // Vereinfachte Version für Längen < 251
        return [self]
    }
}