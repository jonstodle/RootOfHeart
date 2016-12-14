//
//  SettingsService.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 10/12/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import Foundation

class SettingsService {
    fileprivate static func setSetting<T>(value: T, forKey: String) {
        UserDefaults.standard.setValue(value, forKey: forKey)
    }
    
    fileprivate static func getSetting<T>(forKey: String, orDefaultValue defaultValue: T) -> T {
        if let returnValue = UserDefaults.standard.object(forKey: forKey) { return returnValue as! T }
        else { return defaultValue }
    }
}

extension SettingsService {
    static var launchView: LaunchView {
        get { return LaunchView(rawValue: SettingsService.getSetting(forKey: "launchView", orDefaultValue: 1))! }
        set { SettingsService.setSetting(value: newValue.rawValue, forKey: "launchView") }
    }
}

extension SettingsService {
    static var backgroundTime: Int64 {
        get { return SettingsService.getSetting(forKey: "backgroundTime", orDefaultValue: Int64.max) }
        set { SettingsService.setSetting(value: newValue, forKey: "backgroundTime") }
    }
}
