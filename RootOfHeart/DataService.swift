//
//  DataService.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 02/11/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

class DataService{
    //MARK: - Singleton
    
    private static var _instance = DataService()
    static var instance: DataService! { return _instance }
    
    
    
    //MARK: - Private Properties
    
    private let disposeBag = DisposeBag()
    private let realm: Realm!
    
    
    
    //MARK: - Public Properties
    
    let comics: Results<Comic>
    
    
    
    //MARK: - Initializer
    
    private init?(){
        realm = try! Realm()
        
        comics = realm.objects(Comic.self).sorted(byProperty: "number", ascending: false)
        
        getNewComics(from: comics.first?.number)
            .concat(getOldComics(from: comics.last?.number))
            .filter({ $0 != nil })
            .subscribe(onNext: {comic in self.realm.add(comic!)})
            .addDisposableTo(disposeBag)
    }
    
    
    
    // MARK: - Helper Methods
    
    private func getNewComics(from newestComic: Int?) -> Observable<Comic?>{
        return XkcdClient.getCurrentComic()
            .filter{ $0 != nil }
            .flatMap{ comic in XkcdClient.get(comics: Array((newestComic ?? comic!.number)...comic!.number)) }
    }
    
    private func getOldComics(from oldestComic: Int?) -> Observable<Comic?>{
        return XkcdClient.get(comics: Array(1..<(oldestComic ?? 1)))
    }
}
