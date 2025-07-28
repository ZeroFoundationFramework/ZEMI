//
//  ZeroDBTests.swift
//  ZEMI
//
//  Created by Philipp Kotte on 15.07.25.
//
// XCTest Documentation
// https://developer.apple.com/documentation/xctest
// Defining Test Cases and Test Methods
// https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods


import XCTest
@testable import ZeroDB

final class ZeroDBTests: XCTestCase {
    
    var dbClient: MySQLClient!

        // 2. Erstelle die Instanz in der setUp-Methode
        func testSuccessfulLogin() {
            self.dbClient = MySQLClient()
            self.dbClient!.login(username: "admin", password: "admin", database: "mysql")
            
            // Hier kannst du jetzt weitere Asserts hinzufügen, um zu prüfen,
            // ob der Login wirklich erfolgreich war.
        }
    
    
    /*
    func testExample() throws {
        
            client.query(on: "user")
                .select(["User", "Host", "Password"])
                .f_all()
    }
    */
     
    /*
    func testLimit() throws {
            client.query(on: "user")
                .select(["User", "Host", "Password"])
                .limit(1)
                .f_all()
    }
    
    func testFilter() throws {
            client.query(on: "user")
                .select(["User", "Host", "Password"])
                .filter("User", .isEqualTo, "philippkotte")
                .f_all()
    }
    
    
    func testGeneral() throws {
            client.query(on: "user")
                .select(["User", "Host", "Password"])
                .sort("Host", .ascending)
                .sort("User", .ascending)
                .f_all()
    }
    */
    
}

