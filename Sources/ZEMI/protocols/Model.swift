//
//  Model.swift
//  ZEMI
//
//  Created by Philipp Kotte on 14.07.25.
//

import ZeroDB

public protocol Model: Entity, DiscoverableEntity {
    static var keyPathMap: [PartialKeyPath<Self>: String] { get }
    
    init(from row: [String: Any])
}

struct KeyPathWrapper<T>: Hashable {
    let keyPath: PartialKeyPath<T>
    let columnName: String
    
    static func == (lhs: KeyPathWrapper<T>, rhs: KeyPathWrapper<T>) -> Bool {
        return lhs.columnName == rhs.columnName
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(columnName)
    }
}


extension Model {
    static func findBy(_ filters: [PartialKeyPath<Self>: Any]) -> [Self] {
        var whereClauses: [String] = []
        var values: [Any] = []
        
        for (keyPath, value) in filters {
            if let column = Self.keyPathMap[keyPath] {
                whereClauses.append("\(column) = ?")
                values.append(value)
            }
        }
        return []
    }
}

@dynamicMemberLookup
struct Dynamic<T: Model> {
    static subscript(dynamicMember member: String) -> ((Any) -> [T]) {
        return { value in
            guard let column = T.keyPathMap.first(where: { $0.value == member }) else {
                return []
            }
            return T.findBy([column.key: value])
        }
    }
}
