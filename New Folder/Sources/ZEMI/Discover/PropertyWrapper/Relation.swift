//
//  Relation.swift
//  ZEMI
//
//  Created by Philipp Kotte on 14.07.25.
//


@propertyWrapper
struct Relation<T: Model> {
    var wrappedValue: T?
}
