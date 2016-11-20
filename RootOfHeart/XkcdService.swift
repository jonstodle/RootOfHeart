//
//  XkcdService.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 27/10/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON

public class XkcdClient{
    //MARK: - Constants
    
    private static let xkcdUrl = "https://xkcd.com"
    private static let infoSuffix = "/info.0.json"
    
    
    
    //MARK: - Interface
    
    /// Gets the most recent comic
    ///
    /// - returns: The comic that is currently displayed on the landing page xkcd.com
    static func getCurrentComic() -> Observable<Comic?>{
        return get(comic: 0)
    }
    
    /// Gets a comic based on the number passed
    ///
    /// - parameter number: Comic number to get
    ///
    /// - returns: The comic with the indicated number
    static func get(comic number: Int) -> Observable<Comic?>{
        return Observable.create{ observer in
            var disposed = false
            
            if number < 0{
                observer.onNext(nil)
                observer.onCompleted()
            } else{
                let requestUrlInfix = number == 0 ? "" : "/\(number)"
                Alamofire.request("\(xkcdUrl)\(requestUrlInfix)\(infoSuffix)").responseJSON{ response in
                    defer{
                        observer.onCompleted()
                    }
                    
                    guard !disposed else{
                        return
                    }
                    
                    guard response.result.isSuccess else{
                        observer.onNext(nil)
                        return
                    }
                    
                    observer.onNext(createComic(from: JSON(response.result.value!)))
                }
            }
            
            return Disposables.create{
                disposed = true
            }
        }
    }
    
    /// Get a range of comics
    ///
    /// - parameter comics: A range of numbers
    ///
    /// - returns: The comics corresponding to the numbers supplied
    static func get(comics: Int...) -> Observable<Comic?>{
        return get(comics: comics)
    }
    
    static func get(comics: [Int]) -> Observable<Comic?>{
        return Observable.from(comics).flatMap{get(comic: $0)}
    }
    
    
    
    //MARK: - Helper Methods
    
    private static func createComic(from json: JSON) -> Comic{
        let comic = Comic()
        
        comic.title = json["title"].stringValue
        comic.number = json["num"].intValue
        comic.day = json["day"].stringValue
        comic.month = json["month"].stringValue
        comic.year = json["year"].stringValue
        comic.alt = json["alt"].stringValue
        comic.transcript = json["transcript"].stringValue
        comic.imageWebUrl = json["img"].stringValue.replacingOccurrences(of: "http", with: "https")
        comic.link = json["link"].stringValue
        comic.safeTitle = json["safe_title"].stringValue
        comic.news = json["news"].stringValue
        
        return comic
    }
}
