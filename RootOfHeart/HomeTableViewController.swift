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
    @IBOutlet weak var comicSearchBar: UISearchBar!
    
    
    
    //MARK: - Private Properties
    
    fileprivate let _disposeBag = DisposeBag()
    fileprivate let _comicCellIdentifier = "comicCell"
    fileprivate var _allNotificationToken: NotificationToken?
    fileprivate var _favoritesNotificationToken: NotificationToken?
    fileprivate var _unreadNotificationToken: NotificationToken?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false´
        
        tableView.contentOffset = CGPoint(x: 0, y: headerView.frame.height)
        
        _allNotificationToken = DataService.instance.comics.addNotificationBlock({
            if self.headerSegmentedControl.selectedSegmentIndex == 1{
                self.updateTableView(with: $0)
            }
        })
        
        _favoritesNotificationToken = DataService.instance.favoritedComics.addNotificationBlock({
            if self.headerSegmentedControl.selectedSegmentIndex == 0{
                self.updateTableView(with: $0)
            }
        })
        
        _unreadNotificationToken = DataService.instance.unreadComics.addNotificationBlock({
            if self.headerSegmentedControl.selectedSegmentIndex == 2{
                self.updateTableView(with: $0)
            }
        })
        
        searchBarButton.rx
            .tap
            .subscribe(onNext:{
                UIView.transition(with: self.comicSearchBar, duration: 0.3, options: [.transitionCrossDissolve], animations: {
                    self.comicSearchBar.isHidden = !self.comicSearchBar.isHidden
                }, completion: nil)
            })
            .addDisposableTo(_disposeBag)
        
        headerSegmentedControl.rx
            .value
            .subscribe(onNext:{
                _ in
                self.tableView.reloadData()
            })
            .addDisposableTo(_disposeBag)
        
        self.tableView.rx
            .itemSelected
            .subscribe(
                onNext:{ indexPath in
                    let newVc = self.storyboard?.instantiateViewController(withIdentifier: "ComicViewController") as! ComicViewController
                    newVc.comic = self.getCurrentSource()[indexPath.row]
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
        _allNotificationToken?.stop()
    }
    
    
    
    // MARK: - Table View Data Source
    
    fileprivate func getCurrentSource() -> Results<Comic> {
        let i = headerSegmentedControl.selectedSegmentIndex
        
        if i == 0 { return DataService.instance.favoritedComics }
        if i == 2 { return DataService.instance.unreadComics }
        
        return DataService.instance.comics
    }
    
    fileprivate func updateTableView(with realmChanges: RealmCollectionChange<Results<Comic>>) {
        switch realmChanges{
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
    }
}

extension HomeTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return getCurrentSource().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: _comicCellIdentifier, for: indexPath) as! ComicTableViewCell
        
        let comic = getCurrentSource()[indexPath.row]
        
        cell.comicImageView.image = nil
        cell.comicImageView.kf.setImage(with: URL(string: comic.imageUrl))
        cell.favoriteImageView.isHidden = !comic.isFavorite
        cell.unreadImageView.isHidden = comic.isRead
        cell.numberLabel.text = "#\(comic.number)"
        cell.titleLabel.text = comic.title
        cell.dateLabel.text = "\(comic.day).\(comic.month).\(comic.year)"
        
        return cell
    }
}
