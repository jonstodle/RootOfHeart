//
//  AppDelegate.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 27/10/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        prepareForBackground()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        prepareForBackground()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        prepareForForeground()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        prepareForForeground()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func prepareForBackground(){
        DataService.instance.cancelAllOperations()
        SettingsService.backgroundTime = Int64(Date().timeIntervalSinceReferenceDate)
    }
    
    func prepareForForeground(){
        DataService.instance.startLoadingComics()
        if let isPast12Hours = (Calendar.current.date(byAdding: .hour, value: 6, to: Date(timeIntervalSinceReferenceDate: TimeInterval(integerLiteral: SettingsService.backgroundTime)))?.isBefore(date: Date(), granularity: .hour)),
            isPast12Hours {
            if let navController = window!.rootViewController as? UINavigationController,
                let homeController = navController.viewControllers.first as? HomeTableViewController {
            navController.popToRootViewController(animated: false)
            homeController.headerSegmentedControl?.selectedSegmentIndex = SettingsService.launchView.rawValue
            }
        }
    }
}

