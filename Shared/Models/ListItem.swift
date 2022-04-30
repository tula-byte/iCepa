//
//  ListItem.swift
//  tunnel
//
//  Created by Arjun Singh on 7/1/22.
//

import Foundation
import RealmSwift

class ListItem: Object {
    
    init(url: String, userAdded: Bool, list: TulaList) {
        self.url = url
        self.userAdded = userAdded
        self.list = list
    }
    
    @Persisted(primaryKey: true) var url: String = ""
    @Persisted var userAdded: Bool
    @Persisted var list: TulaList
}

// List options
@objc enum TulaList: Int, PersistableEnum {
    case allow = 0 //index 0
    case block = 1 //index 1
    case other = 2 //index 2
}

