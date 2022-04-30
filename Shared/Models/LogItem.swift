//
//  LogItem.swift
//  iCepa
//
//  Created by Arjun Singh on 24/4/2022.
//  Copyright © 2022 Guardian Project. All rights reserved.
//

import Foundation
import RealmSwift

/// Model for a logged packet
class LogItem : Object, ObjectKeyIdentifiable {
    
    init(url: String, dest: PacketDestination, handshakeTime: Int, timestamp: Date) {
        self.url = url
        self.dest = dest
        self.handshakeTime = handshakeTime
        self.timestamp = timestamp
    }
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var url: String
    @Persisted var dest: PacketDestination
    @Persisted var handshakeTime: Int
    @Persisted var timestamp: Date
}

/// Valid Destinations for a logged packet
@objc enum PacketDestination: Int, PersistableEnum {
    case direct = 0
    case tor = 1
    case block = 2
    case other = 3
}
