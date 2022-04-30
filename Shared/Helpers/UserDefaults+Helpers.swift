//
//  UserDefaults+Helpers.swift
//  iCepa
//
//  Created by Arjun Singh on 29/4/2022.
//  Copyright © 2022 Guardian Project. All rights reserved.
//

import Foundation

extension UserDefaults {
    static var shared: UserDefaults {
        return UserDefaults(suiteName: Config.groupId)!
    }
    
    static let torEnabledKey: String = "TorEnabledKey"
    
    static var useTor: Bool {
        return self.shared.bool(forKey: self.torEnabledKey)
    }
    
    static func setUseTor(useTor: Bool) {
        self.shared.set(useTor, forKey: torEnabledKey)
    }
}

