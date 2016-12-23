//
//  SettingsService.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 10/12/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import Foundation
import RxSwift

final class StateService {
    
    // MARK: - Singleton
    
    static let instance = StateService()
    
    
    
    // MARK: - Init
    
    private init() {
        saveValues(from: launchView.asObservable().map { $0.rawValue },
                   for: "launchView")
        saveValues(from: backgroundTime.asObservable(),
                   for: "backgroundTime")
        
        languageOverride.asObservable()
            .subscribe(onNext: {
                if !$0.isEmpty {
                    StateService.setSetting(value: $0, forKey: "languageOverride")
                    StateService.setSetting(value: [$0], forKey: "AppleLanguages")
                }
                else {
                    UserDefaults.standard.removeObject(forKey: "languageOverride")
                    UserDefaults.standard.removeObject(forKey: "AppleLanguages")
                }
            })
            .addDisposableTo(_disposeBag)
    }
    
    
    
    // MARK: - User State
    
    let launchView = Variable(LaunchView(rawValue: StateService.getSetting(forKey: "launchView", orDefaultValue: 1))!)
    let languageOverride = Variable(StateService.getSetting(forKey: "languageOverride", orDefaultValue: ""))
    
    
    
    // MARK: - App State
    
    let backgroundTime = Variable(StateService.getSetting(forKey: "backgroundTime", orDefaultValue: Int64.max))
    
    
    
    // MARK: - Public Helper Methods
    
    static func setSetting<T>(value: T, forKey: String) {
        UserDefaults.standard.setValue(value, forKey: forKey)
    }
    
    static func getSetting<T>(forKey: String, orDefaultValue defaultValue: T) -> T {
        if let returnValue = UserDefaults.standard.object(forKey: forKey) { return returnValue as! T }
        else { return defaultValue }
    }
    
    
    
    // MARK: - Helper Methods
    
    private func saveValues<T>(from observable: Observable<T>, for key: String) {
        observable
            .subscribe(onNext: { StateService.setSetting(value: $0, forKey: key) })
            .addDisposableTo(_disposeBag)
    }
    
    
    
    // MARK: - Private Properites
    
    private let _disposeBag = DisposeBag()
}
