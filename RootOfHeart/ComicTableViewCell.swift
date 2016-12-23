//
//  ComicTableViewCell.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 20/11/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import UIKit

final class ComicTableViewCell: UITableViewCell {
    
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
            
            downloadState = .notLoaded
            downloadImage()
            favoriteImageView.isHidden = !comic.isFavorite
            unreadImageView.isHidden = comic.isRead
            numberLabel.text = "#\(comic.number)"
            titleLabel.text = comic.title
            dateLabel.text = comic.date.string(dateStyle: .short, timeStyle: .none)
        }
    }
    private(set) var downloadState: loadingState = .notLoaded{
        didSet {
            if downloadState == .loading {
                loadingActivityIndicator.startAnimating()
            }
            else {
                loadingActivityIndicator.stopAnimating()
            }
        }
    }
    
    
    
    // MARK: - Public Methods
    
    func downloadImage() {
        guard downloadState == .notLoaded,
            let comic = comic as Comic! else { return }
        
        downloadState = .loading
        comicImageView.kf.setImage(with: URL(string: comic.imageUrl), placeholder: UIImage(), options: [.transition(.fade(0.2))], completionHandler: {
            [weak self] (image, error, cacheType, imageUrl) in
            self!.downloadState = image != nil ? .loaded : .notLoaded
        })
    }
    
    
    
    // MARK: - Implementation
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

enum loadingState {
    case loading
    case loaded
    case notLoaded
}
