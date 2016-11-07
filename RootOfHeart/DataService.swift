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
    
    private let _disposeBag = DisposeBag()
    private let _realm: Realm!
    private let _addSubject = PublishSubject<Comic?>()
    
    
    
    //MARK: - Public Properties
    
    let comics: Results<Comic>
    
    
    
    //MARK: - Public Methods
    
    func refresh() -> Void{
        getNewComics(from: comics.first?.number)
            .subscribe(onNext: {self._addSubject.onNext($0)})
            .addDisposableTo(_disposeBag)
    }
    
    func loadOldComics() -> Void{
        getOldComics(from: comics.last?.number)
            .subscribe(onNext: {self._addSubject.onNext($0)})
            .addDisposableTo(_disposeBag)
    }
    
    
    
    //MARK: - Initializer
    
    private init?(){
        _realm = try! Realm()
        
        comics = _realm.objects(Comic.self).sorted(byProperty: "number", ascending: false)
        
        _addSubject
            .filter{ $0 != nil }
            .buffer(timeSpan: 5, count: 10, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { comics -> Void in
                let realm = self._realm!
                try! realm.write {
                    realm.add(comics.map{$0!})
                }
            })
            .addDisposableTo(_disposeBag)
        
        getNewComics(from: comics.first?.number)
            .concat(getOldComics(from: comics.last?.number))
            .subscribe(onNext: {self._addSubject.onNext($0)})
            .addDisposableTo(_disposeBag)
    }
    
    
    
    // MARK: - Helper Methods
    
    private func getNewComics(from newestComic: Int?) -> Observable<Comic?>{
        func getNewComicsRange(from comic: Comic) -> Observable<Comic?>{
            return Observable.just(newestComic ?? comic.number - 1)
                .map{$0 + 1}
                .filter{$0 < comic.number}
                .flatMap{XkcdClient.get(comics: Array($0..<comic.number))}
        }
        
        return XkcdClient.getCurrentComic()
            .filter{ $0 != nil }
            .flatMap{ comic in
                Observable.just(comic)
                    .concat(getNewComicsRange(from: comic!))
            }
    }
    
    private func getOldComics(from oldestComic: Int?) -> Observable<Comic?>{
        var comicNumber = oldestComic ?? 2
        if comicNumber == 1 {comicNumber = 2}
        return XkcdClient.get(comics: Array(1..<comicNumber).reversed())
    }
}
