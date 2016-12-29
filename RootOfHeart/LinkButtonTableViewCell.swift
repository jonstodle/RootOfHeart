//
//  LinkButtonTableViewCell.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 21/12/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import UIKit
import RxSwift

final class LinkButtonTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var linkButton: UIButton!
    
    
    
    // MARK: - Public Properties
    
    var link: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        linkButton.rx
            .tap
            .subscribe(onNext: {
                [unowned self] _ in
                guard let url = URL(string: self.link) else { return }
                UIApplication.shared.openURL(url)
            })
            .addDisposableTo(_disposeBag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    // MARK: - Private Properties
    
    let _disposeBag = DisposeBag()

}
