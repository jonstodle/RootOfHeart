//
//  Comic.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 27/10/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import Foundation
import RealmSwift

class Comic : Object{
    //MARK: - Properties
    
    dynamic var title = ""
    dynamic var number = 0
    dynamic var link = ""
    var webUrl: URL{return URL(string: "http://xkcd.com/\(number)")!}
    dynamic var safeTitle = ""
    dynamic var day = ""
    dynamic var month = ""
    dynamic var year = ""
    dynamic var news = ""
    dynamic var alt = ""
    dynamic var transcript = ""
    dynamic var imageWebUrl = ""
    var imageUrl: String{return ""}
    dynamic var read = false
    dynamic var favorite = false
    
    
    
    //MARK: - Realm Meta Data
    
    override static func ignoredProperties() -> [String]{
        return ["webUrl", "imageUrl"]
    }
    
    override static func primaryKey() -> String?{
        return "number"
    }
}
