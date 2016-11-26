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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var comicImageView: UIImageView!
    
    
    
    // MARK: - Private Properties
    
    var comic: Comic = Comic()

    
    
    // MARK: - Implementation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self

        title = comic.title
        comicImageView.imageFromUrl(comic.imageWebUrl, completionHandler:{
            self.scrollView.contentSize = self.comicImageView.bounds.size
            self.setZoomLimits()
            self.setInsets()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        setZoomLimits()
        setInsets()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let center = CGPoint(x: (scrollView.bounds.size.width / 2) + scrollView.contentOffset.x, y: (scrollView.bounds.size.height / 2) + scrollView.contentOffset.y)
        
        coordinator.animate(alongsideTransition: { context -> Void in
            self.scrollView.contentOffset = CGPoint(x: center.x - (size.width / 2), y: center.y - (size.height / 2))
        }, completion: nil)
    }
    
    
    
    // MARK: - Helper Methods
    
    fileprivate func setZoomLimits(){
        let horizontalMinimum = (scrollView.frame.width / comicImageView.bounds.width)
        let verticalMinimum = (scrollView.frame.height / comicImageView.bounds.height)
        
        scrollView.minimumZoomScale = min(horizontalMinimum, verticalMinimum) * 0.95
        scrollView.maximumZoomScale = 3
    }
    
    fileprivate func setInsets(){
        let horizontalInset = max(0, (scrollView.frame.width - comicImageView.frame.size.width) / 2)
        let verticalInset = max(0, (scrollView.frame.height - comicImageView.frame.size.height) / 2)
        
        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
}

extension ComicViewController : UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return comicImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        setInsets()
    }
}
