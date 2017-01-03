//
//  UIExtensions.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 22/11/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift

extension UIViewController{
    func displayMessage(message: String, caption: String? = nil){
        let alert = UIAlertController(title: caption, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func prepareView() { _ = view }
}
