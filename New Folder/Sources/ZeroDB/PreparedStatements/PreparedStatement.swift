//
//  PreparedStatement.swift
//  ZEMI
//
//  Created by Philipp Kotte on 16.07.25.
//


/// Hält den Zustand eines vom Server vorbereiteten SQL-Statements.
private struct PreparedStatement {
    let statementId: UInt32
    let columnCount: UInt16
    let paramCount: UInt16
    let columnNames: [String]
}