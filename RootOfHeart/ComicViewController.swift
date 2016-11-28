//
//  ComicViewController.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 22/11/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ComicViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var comicImageView: UIImageView!
    
    
    
    // MARK: - Properties
    
    var comic: Comic = Comic(){
        didSet{
            
        }
    }
    
    
    
    // MARK: - Private Properties
    
    let _disposeBag = DisposeBag()

    
    
    // MARK: - Implementation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 2
        tapRecognizer.rx
            .event
            .subscribe(onNext: {_ in
                let sv = self.scrollView!
                
                sv.setZoomScale(sv.zoomScale > sv.minimumZoomScale ? sv.minimumZoomScale : sv.maximumZoomScale, animated: true)
            })
            .addDisposableTo(_disposeBag)
        view.addGestureRecognizer(tapRecognizer)

        title = comic.title
        comicImageView.imageFromUrl(comic.imageWebUrl, completion:{
            self.postImageLoadSetup()
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
        let center = CGPoint(x: (scrollView.bounds.width / 2) + scrollView.contentOffset.x, y: (scrollView.bounds.height / 2) + scrollView.contentOffset.y)
        let layoutGuidesHeight = topLayoutGuide.length + bottomLayoutGuide.length
        
        coordinator.animate(alongsideTransition: { context -> Void in
            self.scrollView.contentOffset = CGPoint(x: center.x - (size.width / 2), y: center.y - ((size.height - layoutGuidesHeight) / 2))
        }, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ComicOverlayViewController
        destination.comic = comic
    }
    
    
    
    // MARK: - Helper Methods
    
    private func postImageLoadSetup(){
        comicImageView.sizeToFit()
        scrollView.contentSize = comicImageView.bounds.size
        setZoomLimits()
        setInsets()
        scrollView.zoomScale = scrollView.minimumZoomScale
    }
    
    fileprivate func setZoomLimits(){
        let horizontalMinimum = (scrollView.frame.width / comicImageView.bounds.width)
        let verticalMinimum = (scrollView.frame.height / comicImageView.bounds.height)
        
        scrollView.minimumZoomScale = min(horizontalMinimum, verticalMinimum) * 0.95
        scrollView.maximumZoomScale = 3
        if scrollView.zoomScale < scrollView.minimumZoomScale {
            scrollView.zoomScale = scrollView.minimumZoomScale
        }
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
