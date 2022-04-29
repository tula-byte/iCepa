//
//  NetworkMonitor.swift
//  iCepa
//
//  Created by Arjun Singh on 29/4/2022.
//  Copyright © 2022 Guardian Project. All rights reserved.
//

import Foundation
import Network

class NetworkMonitor {
    
    private static let nwConnectedKey = "NetworkConnected"
    
    private static let nwmon = NWPathMonitor()
    
    private static var connected: Bool = false
    
    init() {
        NetworkMonitor.nwmon.pathUpdateHandler = { path in
            if path.status == .satisfied {
                NetworkMonitor.connected = true
                NSLog("TB NW: Connected")
            } else if path.status == .unsatisfied {
                NetworkMonitor.connected = false
            }
        }
            
        let q = DispatchQueue(label: NetworkMonitor.nwConnectedKey)
        
        NetworkMonitor.nwmon.start(queue: q)
    }
    
    deinit {
        NetworkMonitor.nwmon.cancel()
    }
    
    public static func isConnected() -> Bool {
        return NetworkMonitor.connected
    }
}
