//
//  ComicTableViewCell.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 20/11/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import UIKit
import Alamofire

class ComicTableViewCell: UITableViewCell {
    
    // MARK: - Outlets

    @IBOutlet weak var comicImageView: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    
    // MARK: - Methods
    
    func setImage(from url: String) -> Void{
        Alamofire.request(url).responseData{response in
            guard response.result.isSuccess else{ return}
            
            self.comicImageView.image = UIImage(data: response.data!)
        }
    }
    
    
    
    // MARK: - Implementation
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
