//
//  SettingsService.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 10/12/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import Foundation

class SettingsService {
    static func setSetting<T>(value: T, forKey: String) {
        UserDefaults.standard.setValue(value, forKey: forKey)
    }
    
    static func getSetting<T>(forKey: String, orDefaultValue defaultValue: T) -> T {
        if let returnValue = UserDefaults.standard.object(forKey: forKey) { return returnValue as! T }
        else { return defaultValue }
    }
}

extension SettingsService {
    static var launchView: LaunchView {
        get { return LaunchView(rawValue: SettingsService.getSetting(forKey: "launchView", orDefaultValue: 1))! }
        set { SettingsService.setSetting(value: newValue.rawValue, forKey: "launchView") }
    }
    
    static var languageOverride: String {
        get { return SettingsService.getSetting(forKey: "languageOverride", orDefaultValue: "") }
        set {
            if !newValue.isEmpty {
                SettingsService.setSetting(value: newValue, forKey: "languageOverride")
                SettingsService.setSetting(value: [newValue], forKey: "AppleLanguages")
            }
            else {
                UserDefaults.standard.removeObject(forKey: "languageOverride")
                UserDefaults.standard.removeObject(forKey: "AppleLanguages")
            }
        }
    }
}

extension SettingsService {
    static var backgroundTime: Int64 {
        get { return SettingsService.getSetting(forKey: "backgroundTime", orDefaultValue: Int64.max) }
        set { SettingsService.setSetting(value: newValue, forKey: "backgroundTime") }
    }
}
