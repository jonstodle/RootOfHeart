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

final class DataService{
    //MARK: - Singleton
    
    private static var _instance = DataService()
    static var instance: DataService! { return _instance }
    
    
    
    //MARK: - Private Properties
    
    private var _disposeBag = DisposeBag()
    private let _realm: Realm!
    private let _addSubject = PublishSubject<Comic?>()
    
    
    
    //MARK: - Public Properties
    
    let comics: Results<Comic>
    let favoritedComics: Results<Comic>
    let unreadComics: Results<Comic>
    
    let isLoadingOldComics = Variable(false)
    
    
    
    //MARK: - Public Methods
    
    func refresh() -> Observable<[Comic]?>{
        return Observable<[Comic]?>.create{
            [unowned self] o in
            var newComics: [Comic] = []
            
            return self.getNewComics(from: self.comics.first?.number)
                .subscribe(
                    onNext: {
                        [unowned self] comic in
                        self._addSubject.onNext(comic)
                        if let c = comic { newComics.append(c) }
                    },
                    onError: {
                        _ in
                        o.onNext([])
                        o.onCompleted()
                    },
                    onCompleted: {
                        o.onNext(newComics)
                        o.onCompleted()
                    })
        }
    }
    
    func loadOldComics() {
        getOldComics(from: comics.last?.number)
            .subscribe(
                onNext: { [unowned self] comic in self._addSubject.onNext(comic)})
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
        _ = NotificationService.setBadgeToUnreadCount()
        NotificationService.clearNotification(forComic: comic)
    }
    
    func search(for text: String) -> Results<Comic> {
        let textParts = text.characters.split(separator: (" ")).map({ String($0)})
        var predicates: [NSCompoundPredicate] = []
        
        for part in textParts {
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "title CONTAINS[c] %@", part),
                NSPredicate(format: "alt CONTAINS[c] %@", part)
                ]))
        }
        
        return comics.filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
    }
    
    func startLoadingComics() {
        if comics.count == 0 {
            XkcdClient.get(comic: 0)
                .filter({$0 != nil})
                .flatMap{comic in
                    return Observable.just(comic)
                        .concat(XkcdClient.get(comics: Array((comic!.number - 10)..<comic!.number)))
                }
                .subscribe(onNext: {[unowned self] comic in self._addSubject.onNext(comic)})
                .addDisposableTo(_disposeBag)
        } else { loadComics(fromNewestComic: comics.first?.number, toOldestComic: comics.last?.number) }
    }
    
    func cancelAllOperations() {
        _disposeBag = DisposeBag()
    }
    
    
    
    //MARK: - Initializer
    
    private init?(){
        _realm = try! Realm()
        
        comics = _realm.objects(Comic.self).sorted(byProperty: "number", ascending: false)
        favoritedComics = comics.filter("isFavorite == true")
        unreadComics = comics.filter("isRead == false")
        
        _addSubject
            .filter{ $0 != nil }
            .buffer(timeSpan: 2, count: 10, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] comics -> Void in
                let realm = self._realm!
                try! realm.write {
                    realm.add(comics.map{$0!}, update: true)
                }
            })
            .addDisposableTo(_disposeBag)
        
        fixWebUrls()
    }
    
    
    
    // MARK: - Private Methods
    
    private func loadComics(fromNewestComic: Int?, toOldestComic: Int?) -> Void{
        getNewComics(from: fromNewestComic)
            .concat(getOldComics(from: toOldestComic))
            .subscribe(onNext: {[unowned self] comic in self._addSubject.onNext(comic)})
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
            .flatMap{
                comic -> Observable<Comic?> in
                if let newestComic = newestComic,
                    comic!.number != newestComic{
                    return Observable.just(comic)
                        .concat(getNewComicsRange(from: comic!))
                }
                else {
                    return Observable<Comic?>.just(nil)
                }
        }
    }
    
    private func getOldComics(from oldestComic: Int?) -> Observable<Comic?>{
        guard !isLoadingOldComics.value,
            let oldestComic = oldestComic,
            oldestComic != 1 else { return Observable.just(nil) }
        
        return Observable.just(nil)
            .do(onNext: { [unowned self] _ in self.isLoadingOldComics.value = true })
            .concat(XkcdClient.get(comics: Array(1..<oldestComic).reversed())
                .do(onError: { [unowned self] _ in self.isLoadingOldComics.value = false },
                    onCompleted: { [unowned self] in self.isLoadingOldComics.value = false },
                    onDispose: { [unowned self] in self.isLoadingOldComics.value = false}))
            .map({
                comic in
                comic?.isRead = true
                return comic
            })
    }
    
    private func fixWebUrls(){
        Observable<Comic>.from(comics)
            .filter{ $0.imageUrl.contains("httpss") }
            .map{ comic in
                let newComic = Comic()
                newComic.title = comic.title
                newComic.number = comic.number
                newComic.link = comic.link
                newComic.safeTitle = comic.safeTitle
                newComic.day = comic.day
                newComic.month = comic.month
                newComic.year = comic.year
                newComic.news = comic.news
                newComic.alt = comic.alt
                newComic.transcript = comic.transcript
                newComic.imageUrl = comic.imageUrl.replacingOccurrences(of: "httpss", with: "https")
                newComic.isRead = comic.isRead
                newComic.isFavorite = comic.isFavorite
                return newComic
            }
            .subscribe(onNext: { [unowned self] in self._addSubject.onNext($0) })
            .addDisposableTo(_disposeBag)
    }
}
