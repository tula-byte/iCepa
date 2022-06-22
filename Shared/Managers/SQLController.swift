//
//  SQLController.swift
//  iCepa
//
//  Created by Arjun Singh on 9/5/2022.
//  Copyright © 2022 Guardian Project. All rights reserved.
//

import Foundation
import GRDB

/// A helper class to interface with the SQLite database
class SQLController {
    
    /// Singleton reference to the SQLController
    public static let shared = SQLController()
    /// An array to store the current database connection
    var connections: [DatabasePool]  = []
    
    /// Returns a single database connection
    public func getConnection() -> DatabasePool {
        if SQLController.shared.connections.count == 0 {
            let conn: DatabasePool  = try! DatabasePool(path: FileManager.default.sqliteDBFile!.path)
            SQLController.shared.connections.append(conn)
            return SQLController.shared.connections.first!
        }
        return SQLController.shared.connections.first!
    }
    
    public func getLogSize() {
        let conn = SQLController.shared.getConnection()
        try! conn.read({ db in
            let count = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM log")
            print("Log Size: \(count)")
        })
    }
    
}
