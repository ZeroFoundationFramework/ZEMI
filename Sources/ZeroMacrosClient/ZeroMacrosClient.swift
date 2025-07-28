//
//  ZeroMacrosClient.swift
//  ZEMI
//
//  Created by Philipp Kotte on 18.07.25.
//

@attached(member, names: named(CodingKeys))
public macro GenerateCodingKeys() = #externalMacro(
    module: "ZeroMacros",
    type: "GenerateCodingKeysMacro"
)

@attached(member, names: arbitrary)
public macro GenerateQueryFunctions() = #externalMacro(
    module: "ZeroMacros",
    type: "GenerateQueryFunctionsMacro"
)
