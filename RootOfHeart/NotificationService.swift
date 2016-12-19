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
        notification.alertTitle = NSLocalizedString("Unread comic", comment: "")
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
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    static func clearAllNotifications() {
        UIApplication.shared.cancelAllLocalNotifications()
    }
    
    static func clearNotification(forComic comic: Comic) {
        if let notification = UIApplication.shared.scheduledLocalNotifications?.first(where: {
            if let comicNumber = $0.userInfo?["number"] as? Int {
                return comicNumber == comic.number
            }
            else {
                return false
            }
        }) {
            UIApplication.shared.cancelLocalNotification(notification)
        }
    }
}
