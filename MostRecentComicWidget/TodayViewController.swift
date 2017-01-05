//
//  TodayViewController.swift
//  MostRecentComicWidget
//
//  Created by Jon Stødle on 04/01/2017.
//  Copyright © 2017 Jon Stødle. All rights reserved.
//

import UIKit
import NotificationCenter
import RxSwift
import RxCocoa
import Kingfisher

class TodayViewController: UIViewController, NCWidgetProviding {
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var comicImageView: UIImageView!
    
    
    
    
    // MARK: - Implementation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        if #available(iOSApplicationExtension 10.0, *) {
            extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
        
        updateImage().subscribe().addDisposableTo(_disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        updateImage()
            .subscribe(onNext: { completionHandler($0) }, onError: { _ in completionHandler(NCUpdateResult.failed) })
            .addDisposableTo(_disposeBag)
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact { preferredContentSize = maxSize }
        else { preferredContentSize = CGSize(width: 0, height: 300) }
    }
    
    
    
    // MARK: - Helper Methods
    
    private func updateImage() -> Observable<NCUpdateResult> {
        return XkcdClient.getCurrentComic()
            .flatMap {
                [unowned self] comic -> Observable<NCUpdateResult> in
                guard let comic = comic else { return Observable.just(NCUpdateResult.failed) }
                
                self.titleLabel.text = "#\(comic.number) - \(comic.title)"
                
                return Observable<NCUpdateResult>.create {
                    [unowned self] o in
                    self.comicImageView.kf.setImage(with: URL(string: comic.imageUrl)) {
                        image, _, cacheType, _ in
                        if image == nil { o.onNext(NCUpdateResult.failed) }
                        else if cacheType == .disk { o.onNext(NCUpdateResult.noData) }
                        else { o.onNext(NCUpdateResult.newData) }
                    }
                    
                    o.onCompleted()
                    return Disposables.create()
                }
        }
    }
    
    
    
    // MARK: - Private Properites
    
    private let _disposeBag = DisposeBag()
}
