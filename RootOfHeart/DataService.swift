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
    let favoritedComics: Results<Comic>
    let unreadComics: Results<Comic>
    
    
    
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
    
    func getComic(number: Int) -> Comic?{
        return comics.first(where: {$0.number == number})
    }
    
    func setComic(_ comic: Comic, asFavorite: Bool) -> Void{
        try! _realm.write {
            comic.isFavorite = asFavorite
        }
    }
    
    func setComic(_ comic: Comic, asRead: Bool) -> Void {
        try! _realm.write {
            comic.isRead = asRead
        }
    }
    
    
    
    //MARK: - Initializer
    
    private init?(){
        _realm = try! Realm()
        
        comics = _realm.objects(Comic.self).sorted(byProperty: "number", ascending: false)
        favoritedComics = comics.filter("isFavorite == true")
        unreadComics = comics.filter("isRead == false")
        
        _addSubject
            .filter{ $0 != nil }
            .buffer(timeSpan: 5, count: 10, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { comics -> Void in
                let realm = self._realm!
                try! realm.write {
                    realm.add(comics.map{$0!}, update: true)
                }
            })
            .addDisposableTo(_disposeBag)
        
        if comics.count == 0 {
            XkcdClient.get(comic: 0)
                .filter({$0 != nil})
                .flatMap{comic in
                    return Observable.just(comic)
                        .concat(XkcdClient.get(comics: Array((comic!.number - 10)..<comic!.number)))
                }
                .subscribe(onNext: {self._addSubject.onNext($0)})
                .addDisposableTo(_disposeBag)
        } else { loadComics(fromNewestComic: comics.first?.number, toOldestComic: comics.last?.number) }
    }
    
    
    
    // MARK: - Private Methods
    
    private func loadComics(fromNewestComic: Int?, toOldestComic: Int?) -> Void{
        getNewComics(from: fromNewestComic)
            .concat(getOldComics(from: toOldestComic))
            .subscribe(onNext: {self._addSubject.onNext($0)})
            .addDisposableTo(_disposeBag)
    }
    
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
        guard var oldestComic = oldestComic else { return Observable.just(nil) }
        if oldestComic == 1 {oldestComic = 2}
        return XkcdClient.get(comics: Array(1..<oldestComic).reversed())
    }
}
