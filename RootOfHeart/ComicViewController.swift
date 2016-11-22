//
//  ComicViewController.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 22/11/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import UIKit

class ComicViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var comicImageView: UIImageView!
    
    
    
    // MARK: - Private Properties
    
    var comic: Comic = Comic()

    
    
    
    // MARK: - Implementation
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = comic.title
        comicImageView.imageFromUrl(comic.imageWebUrl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
