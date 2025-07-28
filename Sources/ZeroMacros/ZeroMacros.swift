//
//  ZeroMacros.swift
//  ZEMI
//
//  Created by Philipp Kotte on 18.07.25.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ZeroMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        GenerateCodingKeysMacro.self,
        GenerateQueryFunctionsMacro.self
    ]
}
