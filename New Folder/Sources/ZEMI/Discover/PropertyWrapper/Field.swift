//
//  Field.swift
//  ZEMI
//
//  Created by Philipp Kotte on 14.07.25.
//

@propertyWrapper
struct Field<T>{
    var wrappedValue: T
}
