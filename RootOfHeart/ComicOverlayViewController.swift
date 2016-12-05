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

class ComicOverlayViewController: UIViewController {
    
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
        dateLabel.text = "\(comic.day).\(comic.month).\(comic.year)"
        altTextLabel.text = comic.alt
        setFavoriteButtonImage()
        
        favoriteButton.rx
            .tap
            .subscribe(onNext:{_ in
                DataService.instance.setComic(self.comic, asFavorite: !self.comic.favorite)
                self.comic = DataService.instance.getComic(number: self.comic.number)!
                self.setFavoriteButtonImage()
            })
            .addDisposableTo(_disposeBag)
        
        let saveButtonTaps = saveButton.rx
            .tap
            .share()
        
        saveButtonTaps // Has not access to save photos
            .filter{PHPhotoLibrary.authorizationStatus() == .denied}
            .subscribe(onNext:{
                _ in
                self.displayMessage(message: "Go to Settings > √♥︎ and allow access to Photos", caption: "No access to photos")
            })
            .addDisposableTo(_disposeBag)
            
        saveButtonTaps // Has access to save photos
            .filter{PHPhotoLibrary.authorizationStatus() != .denied}
            .observeOn(SerialDispatchQueueScheduler(qos: .userInitiated))
            .subscribe(onNext:{_ in
                guard let image = self.comicImage else{return}
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            })
            .addDisposableTo(_disposeBag)
        
        shareButton.rx
            .tap
            .subscribe(onNext:{_ in
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
    
    
    
    // MARK: - Helper Methods
    
    private func setFavoriteButtonImage(){
        favoriteButton.setImage(comic.favorite ? #imageLiteral(resourceName: "Favorite-Filled") : #imageLiteral(resourceName: "Favorite"), for: .normal)
    }
}
