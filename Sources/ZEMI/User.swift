//
//  User.swift
//  ZEMI
//
//  Created by Philipp Kotte on 14.07.25.
//

import Foundation
import ZeroDB

public final class User: NSObject, Model {

    @ID var id: Int?
    
    @Text var name: String
    
    @Text(nullable: true, maxSize: 20) var email: String = ""

    public required init(from row: [String: Any]) {
        self.id = row["id"] as? Int
        self.name = row["name"] as? String ?? ""
    }

    init(name: String) {
        self.name = name
    }

    public static var keyPathMap: [PartialKeyPath<User>: String] {
        [
            \User.id: "id",
             \User.name: "name"
        ]
    }
    
}

