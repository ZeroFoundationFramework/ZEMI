//
//  Number.swift
//  ZEMI
//
//  Created by Philipp Kotte on 18.07.25.
//

@propertyWrapper
struct Number<T: Numeric> {
    var wrappedValue: T
    
    
    public var nullable: Bool
    
    
    init(wrappedValue: T, nullable: Bool = false) {
        self.wrappedValue = wrappedValue
        self.nullable = nullable
    }
}
