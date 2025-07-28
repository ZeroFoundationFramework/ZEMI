//
//  QueryBuilder.swift
//  ZEMI
//
//  Created by Philipp Kotte on 16.07.25.
//



struct Predicate {
    enum Operator: String {
        case isEqualTo = "="
        case isNotEqualTo = "!="
        case isLessThan = "<"
        case isLessThanOrEqualTo = "<="
        case isGreaterThan = ">"
        case isGreaterThanOrEqualTo = ">="
    }
    
    let column: String
    let op: Operator
    let value: Any
}

struct Sort{
    enum Direction: String {
        case ascending = "ASC"
        case descending = "DESC"
    }
    
    let column: String
    let direction: Direction
}



class QueryBuilder{
    private let table: String
    private var columns: [String] = ["*"]
    private var predicates: [Predicate] = []
    private var sorts: [Sort] = []
    private var limit: Int?
    
    private var database: MySQLClient
    
    init(table: String, database: MySQLClient){
        self.table = table
        self.database = database
    }
    
    func select(_ columns: [String]) -> Self {
        self.columns = columns
        return self
    }
    /// Fügt eine WHERE-Bedingung hinzu.
    func filter(_ column: String, _ op: Predicate.Operator, _ value: Any) -> Self {
        let predicate = Predicate(column: column, op: op, value: value)
        self.predicates.append(predicate)
        return self
    }
    
    /// Fügt eine ORDER BY-Bedingung hinzu.
    func sort(_ column: String, _ direction: Sort.Direction = .ascending) -> Self {
        let sort = Sort(column: column, direction: direction)
        self.sorts.append(sort)
        return self
    }
    
    /// Legt ein LIMIT fest.
    func limit(_ max: Int) -> Self {
        self.limit = max
        return self
    }
    
    // MARK: - Ausführende Methoden
    
    /// Führt die Anfrage aus und gibt alle Ergebnisse zurück.
    func all() -> [[String: Any]] { // Gibt hier ein vereinfachtes Dictionary zurück
        let (sql, bindings) = compile()
        print("Executing: \(sql) with bindings: \(bindings)")
        
        return database.execute(sql, bindings) ?? []
        //return database.execute(sql, bindings) ?? []
    }
    
    func f_all() {
        
        let (sql, bindings) = compile()
        print("Executing and Formatting: \(sql) with bindings: \(bindings)")
        
        let result = database.execute(sql, bindings) ?? []
        
        print(formatAsTable(results: result, columns: columns))
        
    }
    
    /// Führt die Anfrage aus und gibt das erste Ergebnis zurück.
    func first() -> [String: Any]? {
        // Setze das Limit auf 1 und rufe all() auf
        return self.limit(1).all().first
    }
    /// Baut den finalen SQL-String und die gebundenen Werte zusammen.
    private func compile() -> (sql: String, bindings: [Any]) {
        var sql = "SELECT \(columns.joined(separator: ", ")) FROM \(table)"
        var bindings: [Any] = []
        
        // WHERE-Klausel bauen
        if !predicates.isEmpty {
            let clauses = predicates.map { "\($0.column) \($0.op.rawValue) ?" }
            sql += " WHERE " + clauses.joined(separator: " AND ")
            bindings.append(contentsOf: predicates.map { $0.value })
        }
        
        // ORDER BY-Klausel bauen
        if !sorts.isEmpty {
            let clauses = sorts.map { "\($0.column) \($0.direction.rawValue)" }
            sql += " ORDER BY " + clauses.joined(separator: ", ")
        }
        
        // LIMIT-Klausel bauen
        if let limit = limit {
            sql += " LIMIT \(limit)"
        }
        
        return (sql, bindings)
    }
    
    /// Formatiert ein Array von Dictionaries in eine für die Konsole lesbare Tabelle.
    /// - Parameters:
    ///   - results: Das Array von Dictionaries, wobei jedes Dictionary eine Zeile ist.
    ///   - columns: Ein Array mit den Spaltennamen in der gewünschten Reihenfolge.
    /// - Returns: Ein String, der die formatierte Tabelle darstellt.
    func formatAsTable(results: [[String: Any]], columns: [String]) -> String {
        guard !results.isEmpty else {
            return "Leeres Ergebnis."
        }

        // 1. Spaltenbreiten berechnen
        // Wir starten mit der Länge der Überschriften.
        var columnWidths: [String: Int] = [:]
        for column in columns {
            columnWidths[column] = column.count
        }

        // Gehe durch alle Daten, um die maximale Breite für jede Spalte zu finden.
        for row in results {
            for (key, value) in row {
                let valueString = String(describing: value)
                columnWidths[key] = max(columnWidths[key] ?? 0, valueString.count)
            }
        }

        // 2. Tabellen-String zusammenbauen
        var tableString = ""
        let padding = 2 // Zusätzlicher Leerraum in jeder Zelle

        // Hilfsfunktion zum Erstellen einer Zeile
        func createRow(items: [String], isHeader: Bool = false) {
            var rowString = "|"
            for (i, item) in items.enumerated() {
                let column = columns[i]
                let width = columnWidths[column]! + padding
                let paddedItem = item.padding(toLength: width, withPad: " ", startingAt: 0)
                rowString += paddedItem + "|"
            }
            tableString += rowString + "\n"
        }
        
        // Header-Zeile
        createRow(items: columns, isHeader: true)

        // Trennlinie
        var separatorString = "+"
        for column in columns {
            let width = columnWidths[column]! + padding
            separatorString += String(repeating: "-", count: width) + "+"
        }
        tableString += separatorString + "\n"
        
        // Datenzeilen
        for row in results {
            var rowItems: [String] = []
            for column in columns {
                let value = row[column] ?? ""
                rowItems.append(String(describing: value))
            }
            createRow(items: rowItems)
        }

        return tableString
    }
}
