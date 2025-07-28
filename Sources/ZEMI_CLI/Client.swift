//
//  Client.swift
//  ZEMI
//
//  Created by Philipp Kotte on 17.07.25.
//

import Foundation
import ArgumentParser

@main struct ZEMI_CLI: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        abstract: "Client halt und so",
        subcommands: [
            WiesoTest.self
        ])
    
}


struct WiesoTest: AsyncParsableCommand {
    
    @Argument(help: "Hilfetext") var username: String
    
    func run(){
        print("Hallo \(username)")
    }
}
