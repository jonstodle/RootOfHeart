//
//  ComicOverlayViewController.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 28/11/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import UIKit

class ComicOverlayViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var altTextLabel: UILabel!
    
    
    
    // MARK - Properties
    
    var comic = Comic()
    
    
    
    // MARK: - Implementation

    override func viewDidLoad() {
        super.viewDidLoad()

        altTextLabel.text = comic.alt
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
