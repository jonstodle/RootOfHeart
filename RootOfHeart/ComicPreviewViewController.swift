//
//  ComicPreviewViewController.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 03/01/2017.
//  Copyright © 2017 Jon Stødle. All rights reserved.
//

import UIKit
import Kingfisher

class ComicPreviewViewController: UIViewController {
    
    let comic: Comic
    
    private let comicImageView = UIImageView()
    
    init(comic: Comic) {
        self.comic = comic
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let view = UIView()
        
        comicImageView.translatesAutoresizingMaskIntoConstraints = false
        comicImageView.contentMode = .scaleAspectFit
        comicImageView.kf.indicatorType = .activity
        view.addSubview(comicImageView)
        
        comicImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        comicImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        comicImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        comicImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        comicImageView.kf.setImage(with: URL(string: comic.imageUrl))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
