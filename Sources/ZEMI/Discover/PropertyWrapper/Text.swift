//
//  String.swift
//  ZEMI
//
//  Created by Philipp Kotte on 14.07.25.
//


@propertyWrapper
struct Text {
    var wrappedValue: String {
        didSet {
            if(self.wrappedValue.count > maxSize){
                self.wrappedValue = String(self.wrappedValue.prefix(maxSize))
            }
        }
    }
    
    public var nullable: Bool = false
    private var maxSize: Int = 0
    private var name: String = ""
    
    init(wrappedValue: String = "", name: String, nullable: Bool = false, maxSize: Int = 0)  {
        self.name = name
        self.wrappedValue = wrappedValue
        self.maxSize = maxSize
        self.nullable = nullable
    }
    
}

enum TextError: Error {
    case stringTooLong
}
