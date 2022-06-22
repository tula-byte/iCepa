//
//  NetworkMonitor.swift
//  iCepa
//
//  Created by Arjun Singh on 29/4/2022.
//  Copyright © 2022 Guardian Project. All rights reserved.
//

import Foundation
import Network

/// Checks the current network status
class NetworkMonitor {
    /// A key to start a unique DispatchQueue
    private static let nwConnectedKey = "NetworkConnected"
    
    /// A reference to the system Network API class
    private static let nwmon = NWPathMonitor()
    
    /// A simple boolean to store network status
    private static var connected: Bool = false
    
    /// The connection check loop is registered to a dispatch queue on initialisation
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
    /// When the class instance is deinitalised, the check updates are stopped
    deinit {
        NetworkMonitor.nwmon.cancel()
    }
    
    /// A getter for the current network status
    public static func isConnected() -> Bool {
        return NetworkMonitor.connected
    }
}
