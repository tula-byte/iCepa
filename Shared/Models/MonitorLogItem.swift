//
//  MonitorLogItem.swift
//  iCepa
//
//  Created by Arjun Singh on 23/6/2022.
//  Copyright © 2022 Guardian Project. All rights reserved.
//

import Foundation
import GRDB

class MonitorLogItem: Record {
    var id: Int64?
    var timestamp: Date
    var network: MonitorPacketNetwork
    var destination: MonitorPacketDestination
    var handshake: Int
    var domain: String
    
    init(id: Int64?, timestamp: Date, network: MonitorPacketNetwork, destination: MonitorPacketDestination, handshake: Int, domain: String) {
        self.id = id
        self.timestamp = timestamp
        self.network = network
        self.destination = destination
        self.handshake = handshake
        self.domain = domain
        super.init()
    }
    
    override class var databaseTableName: String {"log"}
    
    enum Columns: String, ColumnExpression {
        case id, timestamp, network, destination, handshake, domain
    }
    
    required init(row: Row) {
        self.id = row[Columns.id]
        self.timestamp = row[Columns.timestamp]
        self.network = row[Columns.network]
        self.destination = MonitorPacketDestination.fromString(row[Columns.destination])
        self.handshake = row[Columns.handshake]
        self.domain = row[Columns.domain]
        super.init(row: row)
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.timestamp] = timestamp
        container[Columns.network] = network
        container[Columns.destination] = destination
        container[Columns.handshake] = handshake
        container[Columns.domain] = domain
    }
    
    override func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

//MARK: - Enums
enum MonitorPacketNetwork: String, Encodable {
    case tcp, udp
}

extension MonitorPacketNetwork: DatabaseValueConvertible {}

enum MonitorPacketDestination: String, Encodable {
    case allow, block, tor, other
}

extension MonitorPacketDestination: DatabaseValueConvertible {}

extension MonitorPacketDestination {
    public static func fromString(_ str: String) -> MonitorPacketDestination {
        switch str {
        case "Direct":
            return MonitorPacketDestination.allow
        case "Reject", "TulaBlock":
            return MonitorPacketDestination.block
        case "Tor", "TorDns":
            return MonitorPacketDestination.tor
        default:
            return MonitorPacketDestination.other
        }
    }
}
