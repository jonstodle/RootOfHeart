//
//  NotificationService.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 19/12/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import Foundation
import UIKit

class NotificationService {
    static func createNotification(forComic comic: Comic) -> UILocalNotification {
        let notification = UILocalNotification()
        notification.alertBody = "\(comic.number) - \(comic.title)"
        notification.userInfo = ["number" : comic.number]
        notification.fireDate = Date()
        return notification
    }
    
    static func scheduleNotification(forComic comic: Comic, at date: Date = Date()) {
        let notification = NotificationService.createNotification(forComic: comic)
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    static func scheduleNotification(_ notification: UILocalNotification) {
        UIApplication.shared.presentLocalNotificationNow(notification)
    }
    
    static func getNotification(forComic comic: Comic) -> UILocalNotification? {
        return UIApplication.shared.scheduledLocalNotifications?.first(where: {
            notification in
            guard let comicNumber = notification.userInfo?["number"] as? Int else { return false }
            return comicNumber == comic.number
        })
    }
    
    static func setBadgeToUnreadCount() {
        UIApplication.shared.applicationIconBadgeNumber = DataService.instance.unreadComics.count
    }
    
    static func clearAllNotifications() {
        UIApplication.shared.cancelAllLocalNotifications()
    }
    
    static func clearNotification(forComic comic: Comic) {
        if let notification = NotificationService.getNotification(forComic: comic) {
            UIApplication.shared.cancelLocalNotification(notification)
        }
    }
}
