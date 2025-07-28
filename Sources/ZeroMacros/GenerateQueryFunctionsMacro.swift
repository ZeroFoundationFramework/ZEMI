//
//  GenerateQueryFunctions.swift
//  ZEMI
//
//  Created by Philipp Kotte on 18.07.25.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


public struct GenerateQueryFunctionsMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        var className: String?
            
            if let classDecl = declaration.as(ClassDeclSyntax.self) {
                className = classDecl.name.text
            } else if let structDecl = declaration.as(StructDeclSyntax.self) {
                className = structDecl.name.text
            }
        
        let members = declaration.memberBlock.members
        let variableDecls = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        
        let propertyNames = variableDecls.flatMap { varDecl -> [(name: String, type: String)] in
            return varDecl.bindings.compactMap { binding -> (name: String, type: String)? in
                guard let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
                    return nil
                }
                // Check for property wrapper and try to extract the wrapped type
                if
                    let wrapperAttr = varDecl.attributes.first,
                    let wrapperName = wrapperAttr.as(AttributeSyntax.self)?.attributeName.as(
                        IdentifierTypeSyntax.self
                    )?.name.text
                {
                    // Try to extract type from property wrapper, fallback to type annotation
                    if let type = binding.typeAnnotation?.type.trimmed.description {
                        return (name: name, type: type)
                    } else if wrapperName == "ID" {
                        // Default to UUID for @ID if not explicitly typed
                        return (name: name, type: "UUID")
                    }
                }
                // No wrapper, fall back to type annotation
                if let type = binding.typeAnnotation?.type.trimmed.description {
                    return (name: name, type: type)
                }
                return nil
            }
        }
        
        var functions = """
        """
        
        propertyNames.forEach{ property in
            
            functions += """
                public static func findBy\(String(property.name.first!).capitalized + property.name.dropFirst())( _ t : \(property.type) )
                """
            
            if let name = className {
                functions += """
                 -> \(name)? 
                """
            }
            
            functions += """
                { \n    return nil \n} \n
                """
        }
        
        print(functions)
        
        let funcDecl: DeclSyntax = DeclSyntax(stringLiteral: functions)
        
        return [funcDecl]
    }
}

