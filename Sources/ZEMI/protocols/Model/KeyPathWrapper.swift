//
//  KeyPathWrapper.swift
//  ZEMI
//
//  Created by Philipp Kotte on 17.07.25.
//

import Foundation

public struct KeyPathWrapper<T>: Hashable {
    let keyPath: PartialKeyPath<T>
    let columnName: String
    
    public static func == (lhs: KeyPathWrapper<T>, rhs: KeyPathWrapper<T>) -> Bool {
        return lhs.columnName == rhs.columnName
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(columnName)
    }
}
