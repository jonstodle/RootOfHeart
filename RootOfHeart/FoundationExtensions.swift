//
//  FoundationExtensions.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 18/12/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(withComment comment: String) -> String {
        return NSLocalizedString(self, comment: comment)
    }
}
