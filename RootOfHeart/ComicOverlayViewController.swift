//
//  ComicOverlayViewController.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 28/11/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import UIKit
import Photos
import RxSwift
import RxCocoa

final class ComicOverlayViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var altTextLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    
    
    // MARK: - Private Properties
    
    let _disposeBag = DisposeBag()
    
    
    
    // MARK: - Public Properties
    
    var comic = Comic()
    var comicImage: UIImage?
    
    
    
    // MARK: - Implementation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberLabel.text = "#\(comic.number)"
        dateLabel.text = comic.date.string(dateStyle: .short, timeStyle: .none)
        altTextLabel.text = comic.alt
        
        favoriteButton.rx
            .tap
            .subscribe(onNext:{
                [unowned self] _ in
                DataService.instance.setComic(self.comic, asFavorite: !self.comic.isFavorite)
                self.comic = DataService.instance.getComic(number: self.comic.number)!
            })
            .addDisposableTo(_disposeBag)
        
        comic.rx.observe(Bool.self, "isFavorite")
            .asDriver(onErrorJustReturn: false)
            .map { $0 ?? false ? #imageLiteral(resourceName: "Favorite-Filled") : #imageLiteral(resourceName: "Favorite") }
            .drive(onNext: { [unowned self] in self.favoriteButton.setImage($0, for: .normal) })
            .addDisposableTo(_disposeBag)
        
        let saveButtonTaps = saveButton.rx
            .tap
            .share()
        
        saveButtonTaps // Has not access to save photos
            .filter{PHPhotoLibrary.authorizationStatus() == .denied}
            .subscribe(onNext:{
                [unowned self] _ in
                self.displayMessage(message: NSLocalizedString("Go to Settings > √♥︎ and allow access to Photos", comment: ""), caption: NSLocalizedString("No access to photos", comment: ""))
            })
            .addDisposableTo(_disposeBag)
            
        saveButtonTaps // Has access to save photos
            .filter{PHPhotoLibrary.authorizationStatus() != .denied}
            .observeOn(SerialDispatchQueueScheduler(qos: .userInitiated))
            .subscribe(onNext:{
                [unowned self] _ in
                guard let image = self.comicImage else{return}
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            })
            .addDisposableTo(_disposeBag)
        
        shareButton.rx
            .tap
            .subscribe(onNext:{
                [unowned self] _ in
                var shareData: [Any] = [self.comic.title, self.comic.webUrl.absoluteString]
                if let image = self.comicImage { shareData.insert(image, at: 0) }
                self.present(UIActivityViewController(activityItems: shareData, applicationActivities: nil), animated: true, completion: nil)
            })
            .addDisposableTo(_disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
