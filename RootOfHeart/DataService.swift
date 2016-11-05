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
    private let addSubject = PublishSubject<Comic?>()
    
    
    
    //MARK: - Public Properties
    
    let comics: Results<Comic>
    
    
    
    //MARK: - Public Methods
    
    func refresh() -> Void{
        getNewComics(from: comics.first?.number)
            .subscribe(onNext: {self.addSubject.onNext($0)})
            .addDisposableTo(disposeBag)
    }
    
    func loadOldComics() -> Void{
        getOldComics(from: comics.last?.number)
            .subscribe(onNext: {self.addSubject.onNext($0)})
            .addDisposableTo(disposeBag)
    }
    
    
    
    //MARK: - Initializer
    
    private init?(){
        realm = try! Realm()
        
        comics = realm.objects(Comic.self).sorted(byProperty: "number", ascending: false)
        
        addSubject
            .filter{ $0 != nil }
            .subscribe(onNext: {self.realm.add($0!)})
            .addDisposableTo(disposeBag)
        
        getNewComics(from: comics.first?.number)
            .concat(getOldComics(from: comics.last?.number))
            .subscribe(onNext: {self.addSubject.onNext($0)})
            .addDisposableTo(disposeBag)
    }
    
    
    
    // MARK: - Helper Methods
    
    private func getNewComics(from newestComic: Int?) -> Observable<Comic?>{
        return XkcdClient.getCurrentComic()
            .filter{ $0 != nil }
            .flatMap{ comic in
                Observable.just(comic)
                    .concat(XkcdClient.get(comics: Array(((newestComic ?? (comic!.number - 1)) + 1)..<comic!.number)))
            }
    }
    
    private func getOldComics(from oldestComic: Int?) -> Observable<Comic?>{
        return XkcdClient.get(comics: Array(1..<(oldestComic ?? 2)).reversed())
    }
}
