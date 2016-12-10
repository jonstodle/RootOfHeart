//
//  LaunchView.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 10/12/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import Foundation

enum LaunchView: Int {
    case favorites = 0
    case all = 1
    case unread = 2
    
    var stringValue: String {
        switch self {
        case .favorites:
            return "Favorites"
        case .all:
            return "All"
        case .unread:
            return "Unread"
        }
    }
}
