//
//  ZeroMacrosTest.swift
//  ZEMI
//
//  Created by Philipp Kotte on 18.07.25.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import ZeroMacros

nonisolated(unsafe) let testMacros : [String: Macro.Type] = [
    "GenerateQueryFunctions" : GenerateQueryFunctionsMacro.self,
]

final class ZeroMacrosTest: XCTestCase {

    func testGeneration() {
        assertMacroExpansion("""
            import Foundation
            import ZeroMacrosClient

            @GenerateQueryFunctions
            public class User: NSObject, Model {
                
                @ID var id: UUID
                
                @Text(name: "name", maxSize: 4) var name: String
                
                @Text(name: "email", nullable: true, maxSize: 20) var email: String
            
                public func test(name: String) -> String {
                    return "Hallo"
                }
            } 
            """, expandedSource: """
                import Foundation
                import ZeroMacrosClient
                public class User: NSObject, Model {
                    
                    @ID var id: UUID
                    
                    @Text(name: "name", maxSize: 4) var name: String
                    
                    @Text(name: "email", nullable: true, maxSize: 20) var email: String

                    public static func findById( _ t : UUID ) -> User? {
                        return nil
                    }
                    public static func findByName( _ t : String ) -> User? { 
                        return nil 
                    } 
                    public static func findByEmail( _ t : String ) -> User? { 
                        return nil 
                    }
                } 
                """, macros: testMacros)
    }
    
    
    /*
     override func setUpWithError() throws {
         // Put setup code here. This method is called before the invocation of each test method in the class.
     }

     override func tearDownWithError() throws {
         // Put teardown code here. This method is called after the invocation of each test method in the class.
     }

     func testExample() throws {
         // This is an example of a functional test case.
         // Use XCTAssert and related functions to verify your tests produce the correct results.
         // Any test you write for XCTest can be annotated as throws and async.
         // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
         // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
     }

     func testPerformanceExample() throws {
         // This is an example of a performance test case.
         self.measure {
             // Put the code you want to measure the time of here.
         }
     }
     */

}
