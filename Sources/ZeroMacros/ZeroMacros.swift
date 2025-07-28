//
//  ZeroMacros.swift
//  ZEMI
//
//  Created by Philipp Kotte on 18.07.25.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct GenerateCodingKeysMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        let members = declaration.memberBlock.members
        let variableDecls = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        
        let propertyNames = variableDecls.flatMap { varDecl in
            varDecl.bindings.compactMap { $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.text }
        }
        
        let caseDecls = propertyNames.map { "case \($0)" }.joined(separator: "\n    ")
        
        let enumDecl: DeclSyntax = """
        enum CodingKeys: String {
            \(raw: caseDecls)
        }
        """
        
        return [enumDecl]
    }
}
