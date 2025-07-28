//
//  ID.swift
//  ZEMI
//
//  Created by Philipp Kotte on 14.07.25.
//
import Foundation

@propertyWrapper
struct ID {
    var wrappedValue: UUID
    
    let autoGenerate: Bool
    
    init(autoGenerate: Bool = true) {
        self.wrappedValue = autoGenerate ? UUID() : UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        self.autoGenerate = autoGenerate
    }
}
