//
//  ComicTableViewCell.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 20/11/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift

class ComicTableViewCell: UITableViewCell {
    
    // MARK: - Outlets

    @IBOutlet weak var comicImageView: UIImageView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var unreadImageView: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    
    // MARK: - Public Properties
    
    var comic: Comic?{
        didSet{
            guard let comic = comic as Comic! else { return }
            
            comicImageView.image = nil
            comicImageView.kf.setImage(with: URL(string: comic.imageUrl))
            favoriteImageView.isHidden = !comic.isFavorite
            unreadImageView.isHidden = comic.isRead
            numberLabel.text = "#\(comic.number)"
            titleLabel.text = comic.title
            dateLabel.text = "\(comic.day).\(comic.month).\(comic.year)"
        }
    }
    private(set) var downloadState: loadingState = .downloading
    
    
    
    // MARK: - Private Properties
    
    private let _disposeBag = DisposeBag()
    
    
    
    // MARK: - Public Methods
    
    func retryImageDownload() {
        guard downloadState == .notDownloaded,
            let comic = comic as Comic! else { return }
        
        comicImageView.kf.setImage(with: URL(string: comic.imageUrl))
        loadingActivityIndicator.startAnimating()
    }
    
    
    
    // MARK: - Implementation
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        downloadState = .downloading
        
        comicImageView.rx.observe(UIImage.self, "image")
            .subscribe(onNext: {
                image in
                self.loadingActivityIndicator.stopAnimating()
                
                if image != nil {
                    self.downloadState = .downloaded
                }
                else {
                    self.downloadState = .notDownloaded
                }
            })
            .addDisposableTo(_disposeBag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

enum loadingState {
    case downloading
    case downloaded
    case notDownloaded
}
