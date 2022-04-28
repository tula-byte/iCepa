//
//  LogItem.swift
//  iCepa
//
//  Created by Arjun Singh on 24/4/2022.
//  Copyright © 2022 Guardian Project. All rights reserved.
//

import Foundation

/// Model for a logged packet
struct LogItem : Identifiable {
    let id = UUID()
    var url: String
    var dest: PacketDestination
    var handshakeTime: Int
    var timestamp: Date
}

/// Valid Destinations for a logged packet
enum PacketDestination {
    case direct, tor, block, other
}
