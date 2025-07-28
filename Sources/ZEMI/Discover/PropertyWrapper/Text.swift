//
//  String.swift
//  ZEMI
//
//  Created by Philipp Kotte on 14.07.25.
//


@propertyWrapper
struct Text {
    var wrappedValue: String
    
    let nullable: Bool
    let maxSize: Int
    
    init(wrappedValue: String, nullable: Bool = false, maxSize: Int = 0) {
        self.wrappedValue = wrappedValue
        self.nullable = nullable
        self.maxSize = maxSize
    }
    
}
