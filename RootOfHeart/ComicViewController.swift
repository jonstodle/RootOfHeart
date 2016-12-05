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
    @IBOutlet weak var overlayContainerView: UIView!
    
    
    
    // MARK: - Properties
    
    var comic: Comic = Comic()
    
    
    
    // MARK: - Private Properties
    
    let _disposeBag = DisposeBag()
    var overlayViewController: ComicOverlayViewController = ComicOverlayViewController()

    
    
    // MARK: - Implementation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self

        title = comic.title
        comicImageView.imageFromUrl(comic.imageWebUrl, completion:{
            self.postImageLoadSetup()
        })
        
        let doubleTapRecognizer = UITapGestureRecognizer()
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.rx
            .event
            .subscribe(onNext: {_ in
                let sv = self.scrollView!
                let iv = self.comicImageView!
                
                let horizontalFitScale = sv.frame.width / iv.bounds.width;
                let verticalFitScale = sv.frame.height / iv.bounds.height;
                let zoomedInScale = max(horizontalFitScale, verticalFitScale) * 0.95
                
                
                sv.setZoomScale(sv.zoomScale < zoomedInScale ? zoomedInScale : sv.minimumZoomScale, animated: true)
            })
            .addDisposableTo(_disposeBag)
        view.addGestureRecognizer(doubleTapRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.rx
            .event
            .flatMap({Observable.just($0).delay(0.3, scheduler: ConcurrentDispatchQueueScheduler(qos: .background)).takeUntil(doubleTapRecognizer.rx.event)})
            .observeOn(MainScheduler.instance)
            .subscribe(onNext:{_ in
                UIView.transition(with: self.overlayContainerView, duration: 0.3, options: [.transitionCrossDissolve], animations: {
                    self.overlayViewController.comicImage = self.comicImageView.image
                    self.overlayContainerView.isHidden = !self.overlayContainerView.isHidden
                }, completion: nil)
            })
            .addDisposableTo(_disposeBag)
        view.addGestureRecognizer(tapRecognizer)
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
        overlayViewController = segue.destination as! ComicOverlayViewController
        overlayViewController.comic = comic
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
