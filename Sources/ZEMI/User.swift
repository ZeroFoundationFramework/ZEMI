//
//  User.swift
//  ZEMI
//
//  Created by Philipp Kotte on 14.07.25.
//

import Foundation
import ZeroDB
import ZeroMacrosClient

@GenerateQueryFunctions
public class User: NSObject, Model {
    
    @ID var id: UUID
    
    @Text(name: "name", maxSize: 4) var name: String
    
    @Text(name: "email", nullable: true, maxSize: 20) var email: String
    
    public func toString() -> String {
        "User(id: \(id), name: \(name))"
    }
}
