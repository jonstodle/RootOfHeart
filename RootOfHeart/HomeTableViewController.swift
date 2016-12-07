//
//  HomeViewController.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 27/10/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift
import Kingfisher

class HomeTableViewController: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var settingsBarButton: UIBarButtonItem!
    @IBOutlet weak var searchBarButton: UIBarButtonItem!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerSegmentedControl: UISegmentedControl!
    
    
    
    //MARK: - Private Properties
    
    fileprivate let _disposeBag = DisposeBag()
    fileprivate let _comicCellIdentifier = "comicCell"
    fileprivate var _notificationToken: NotificationToken?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false´
        
        tableView.contentOffset = CGPoint(x: 0, y: headerView.frame.height)
        
        _notificationToken = DataService.instance.comics.addNotificationBlock({ changes in
            guard let tableView = self.tableView else{return}
            
            switch changes{
            case .initial:
                tableView.reloadData()
                break
            case .update(_, deletions: let deletions, insertions: let insertions, modifications: let modifcations):
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map{IndexPath(row: $0, section: 0)}, with: .automatic)
                tableView.deleteRows(at: deletions.map{IndexPath(row: $0, section: 0)}, with: .automatic)
                tableView.reloadRows(at: modifcations.map{IndexPath(row: $0, section: 0)}, with: .automatic)
                tableView.endUpdates()
                break
            case .error:
                // Handle error
                break
            }
        })
        
        self.tableView.rx
            .itemSelected
            .subscribe(
                onNext:{ indexPath in
                    let newVc = self.storyboard?.instantiateViewController(withIdentifier: "ComicViewController") as! ComicViewController
                    newVc.comic = DataService.instance.comics[indexPath.row]
                    self.navigationController?.pushViewController(newVc, animated: true)
                })
            .addDisposableTo(_disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Initializers
    
    deinit {
        _notificationToken?.stop()
    }
}

extension HomeTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return DataService.instance.comics.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: _comicCellIdentifier, for: indexPath) as! ComicTableViewCell
        
        let comic = DataService.instance.comics[indexPath.row]
        
        cell.comicImageView.image = nil
        cell.comicImageView.kf.setImage(with: URL(string: comic.imageUrl))
        cell.numberLabel?.text = "#\(comic.number)"
        cell.titleLabel?.text = comic.title
        cell.dateLabel?.text = "\(comic.day).\(comic.month).\(comic.year)"
        
        return cell
    }
}
