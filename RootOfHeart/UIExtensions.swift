//
//  UIExtensions.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 22/11/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import UIKit
import Alamofire

extension UIImageView{
    func imageFromUrl(_ url: String, completion: @escaping () -> Void) -> Void{
        Alamofire.request(url).responseData{response in
            guard response.result.isSuccess else{ return}
            
            self.image = UIImage(data: response.data!)
            
            completion()
        }
    }
    
    func imageFromUrl(_ url: String) -> Void{
        imageFromUrl(url, completion: {})
    }
}

extension UIViewController{
    func displayMessage(message: String, caption: String? = nil){
        let alert = UIAlertController(title: caption, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
