//
//  FileService.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 05/12/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import UIKit
import Foundation
import RxSwift

class FileService {
    static func saveImageToCache(name: String, image: UIImage) -> Observable<Bool>{
        return Observable<Bool>.create{
            o in
            var disposed = false;
            
            let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
            let filePath = paths.first!.appending("/\(name)")
            
            if !disposed {
                try? UIImageJPEGRepresentation(image, 1.0)?.write(to: URL(fileURLWithPath: filePath))
                
                o.onNext(true)
                o.onCompleted()
            }
            
            return Disposables.create {
                disposed = true
            }
        }
    }
    
    static func loadImageFromCache(name: String) -> Observable<UIImage?> {
        return Observable.create{
            o in
            var disposed = false
            
            let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
            let filePath = paths.first!.appending(name)
            
            if !disposed {
                o.onNext(UIImage(contentsOfFile: filePath))
                o.onCompleted()
            }
            
            return Disposables.create {
                disposed = true
            }
        }
    }
}
