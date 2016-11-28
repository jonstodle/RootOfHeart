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
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var altTextLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    
    
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
