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
}

