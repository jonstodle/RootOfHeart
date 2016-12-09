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
    
    
    
    // MARK: - Private Properties
    
    private let _disposeBag = DisposeBag()
    
    
    
    // MARK: - Implementation
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        comicImageView.rx.observe(UIImage.self, "image")
            .subscribe(onNext: {
                image in
                if image == nil {
                    self.loadingActivityIndicator.startAnimating()
                }
                else {
                    self.loadingActivityIndicator.stopAnimating()
                }
            })
            .addDisposableTo(_disposeBag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
