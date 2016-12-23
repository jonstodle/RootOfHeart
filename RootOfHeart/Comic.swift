//
//  Comic.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 27/10/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftDate

final class Comic : Object{
    //MARK: - Properties
    
    dynamic var title = ""
    dynamic var number = 0
    dynamic var link = ""
    dynamic var safeTitle = ""
    dynamic var day = ""
    dynamic var month = ""
    dynamic var year = ""
    dynamic var news = ""
    dynamic var alt = ""
    dynamic var transcript = ""
    dynamic var imageUrl = ""
    dynamic var isRead = false
    dynamic var isFavorite = false
    
    
    
    //MARK: - Realm Meta Data
    
    override static func primaryKey() -> String?{
        return "number"
    }
}

extension Comic {
    var webUrl: URL{return URL(string: "http://xkcd.com/\(number)")!}
    var date: DateInRegion { return try! DateInRegion(string: "\(day).\(month).\(year)", format: .custom("dd.MM.yyyy")) }
}
