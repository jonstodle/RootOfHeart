//
//  AppDelegate.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 27/10/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import UIKit
import RxSwift
import MobileCenter
import MobileCenterAnalytics
import MobileCenterCrashes

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        MSMobileCenter.start("6ee0ec3a-ddd6-4c4f-82dc-776ef885fcc2", withServices:[
            MSAnalytics.self,
            MSCrashes.self
            ])
        #if DEBUG
            MSMobileCenter.setEnabled(false)
        #endif
        
        prepareForForeground()
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .alert], categories: nil))
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
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
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        DataService.instance.refresh()
            .subscribe(onNext: {
            result in
            guard let result = result else {
                completionHandler(.failed)
                return
            }
            
            for comic in result {
                NotificationService.scheduleNotification(forComic: comic)
            }
            
            NotificationService.setBadgeToUnreadCount()
            
            completionHandler(result.count > 0 ? .newData : .noData)
        })
        .addDisposableTo(_disposeBag)
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        guard application.applicationState != .active else { return }
        
        guard let navController = window?.rootViewController as? UINavigationController,
            let homeController = navController.viewControllers.first as? HomeTableViewController,
            let storyBoard = homeController.storyboard,
            let comicNumber = notification.userInfo?["number"] as? Int else { return }
        
        navController.popViewController(animated: false)
        let newVc = storyBoard.instantiateViewController(withIdentifier: "ComicViewController") as! ComicViewController
        newVc.comic = DataService.instance.getComic(number: comicNumber)!
        navController.pushViewController(newVc, animated: true)
    }
    
    
    
    // MARK: - Helper Methods
    
    func prepareForBackground(){
        DataService.instance.cancelAllOperations()
        StateService.instance.backgroundTime.value = Int64(Date().timeIntervalSinceReferenceDate)
    }
    
    func prepareForForeground(){
        DataService.instance.startLoadingComics()
        if let isPast12Hours = (Calendar.current.date(byAdding: .hour, value: 6, to: Date(timeIntervalSinceReferenceDate: TimeInterval(integerLiteral: StateService.instance.backgroundTime.value)))?.isBefore(date: Date(), granularity: .hour)),
            isPast12Hours {
            if let navController = window!.rootViewController as? UINavigationController,
                let homeController = navController.viewControllers.first as? HomeTableViewController {
                navController.popToRootViewController(animated: false)
                homeController.headerSegmentedControl?.selectedSegmentIndex = StateService.instance.launchView.value.rawValue
                homeController.tableView.reloadData()
            }
        }
    }
    
    
    
    // MARK: - Private Properties
    
    private let _disposeBag = DisposeBag()
}

