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

final class HomeTableViewController: UITableViewController {
    
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
    
    
    
    // MARK: - Implementation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "√♥︎"
        navigationItem.title = title
        
        headerSegmentedControl.setTitle(NSLocalizedString("Favorites", comment: ""), forSegmentAt: 0)
        headerSegmentedControl.setTitle(NSLocalizedString("All", comment: ""), forSegmentAt: 1)
        headerSegmentedControl.setTitle(NSLocalizedString("Unread", comment: ""), forSegmentAt: 2)
        
        tableView.contentOffset = CGPoint(x: 0, y: headerView.frame.height)
        headerSegmentedControl.selectedSegmentIndex = StateService.instance.launchView.value.rawValue
        
        _allNotificationToken = DataService.instance.comics.addNotificationBlock({
            [unowned self] in
            if self.headerSegmentedControl.selectedSegmentIndex == 1{
                self.updateTableView(with: $0)
            }
        })
        
        _favoritesNotificationToken = DataService.instance.favoritedComics.addNotificationBlock({
            [unowned self] in
            if self.headerSegmentedControl.selectedSegmentIndex == 0{
                self.updateTableView(with: $0)
            }
        })
        
        _unreadNotificationToken = DataService.instance.unreadComics.addNotificationBlock({
            [unowned self] in
            if self.headerSegmentedControl.selectedSegmentIndex == 2{
                self.updateTableView(with: $0)
            }
        })
        
        settingsBarButton.rx
            .tap
            .subscribe(onNext: {
                [unowned self] _ in
                let newVc = self.storyboard!.instantiateViewController(withIdentifier: "SettingsTabBarController")
                self.navigationController?.pushViewController(newVc, animated: true)
            })
            .addDisposableTo(_disposeBag)
        
        searchBarButton.rx
            .tap
            .subscribe(onNext:{
                [unowned self] _ in
                if self.comicSearchBar.isHidden { self.tableView.setContentOffset(CGPoint(x: 0, y: -self.topLayoutGuide.length), animated: true) }
                UIView.transition(with: self.comicSearchBar, duration: 0.3, options: [.transitionCrossDissolve], animations: {
                    self.comicSearchBar.isHidden = !self.comicSearchBar.isHidden
                }, completion: {
                    finished in
                    if !self.comicSearchBar.isHidden {
                        self.comicSearchBar.becomeFirstResponder()
                    }
                    else {
                        self.comicSearchBar.resignFirstResponder()
                        self.comicSearchBar.text = ""
                        self.tableView.reloadData()
                    }
                })
            })
            .addDisposableTo(_disposeBag)
        
        refreshControl?.rx
            .controlEvent(UIControlEvents.valueChanged)
            .flatMap {
                Observable.combineLatest(
                    DataService.instance.refresh(),
                    Observable<Int>.timer(2, scheduler: ConcurrentDispatchQueueScheduler.init(qos: .utility))) { $0 }
                .take(1)
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] _ in
                    self.refreshControl?.endRefreshing()
            })
            .addDisposableTo(_disposeBag)
        
        headerSegmentedControl.rx
            .value
            .subscribe(onNext:{
                [unowned self] _ in
                self.tableView.reloadData()
            })
            .addDisposableTo(_disposeBag)
        
        comicSearchBar.rx
            .text
            .debounce(0.8, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                [unowned self] _ in
                self.tableView.reloadData()
            })
            .addDisposableTo(_disposeBag)
        
        comicSearchBar.rx
            .text
            .filter { $0?.isEmpty ?? true }
            .subscribe(onNext: {
                [unowned self] _ in
                self.tableView.reloadData()
            })
            .addDisposableTo(_disposeBag)
        
        comicSearchBar.rx
            .searchButtonClicked
            .subscribe(onNext: {
                [unowned self] _ in
                self.comicSearchBar.resignFirstResponder()
            })
            .addDisposableTo(_disposeBag)
        
        tableView.rx
            .itemSelected
            .subscribe(
                onNext:{
                    [unowned self] indexPath in
                    let cell = self.tableView.cellForRow(at: indexPath) as! ComicTableViewCell
                    
                    if cell.downloadState == .loaded {
                        let newVc = self.storyboard?.instantiateViewController(withIdentifier: "ComicViewController") as! ComicViewController
                        newVc.comic = self._dataSource[indexPath.row]
                        self.navigationController?.pushViewController(newVc, animated: true)
                    }
                    else {
                        cell.downloadImage()
                    }
            })
            .addDisposableTo(_disposeBag)
        
        tableView.rx
            .willDisplayCell
            .subscribe(onNext: {
                [unowned self] _, indexPath in
                
                if indexPath.row >= (self.tableView.numberOfRows(inSection: 0) - 3) {
                    DataService.instance.loadOldComics()
                }
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
        _favoritesNotificationToken?.stop()
        _unreadNotificationToken?.stop()
    }
    
    
    
    // MARK: - Table View Data Source
    
    fileprivate var _dataSource: Results<Comic> {
        if !(comicSearchBar.text?.isEmpty ?? true) {
            return DataService.instance.search(for: comicSearchBar.text!)
        }
        else {
            switch headerSegmentedControl.selectedSegmentIndex {
            case 0: return DataService.instance.favoritedComics
            case 2: return DataService.instance.unreadComics
            default: return DataService.instance.comics
            }
        }
    }
    
    fileprivate func updateTableView(with realmChanges: RealmCollectionChange<Results<Comic>>) {
        guard comicSearchBar.text?.isEmpty ?? true else { return }
        
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
        if _dataSource.count == 0 {
            let containerView = UIView()
            
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.distribution = .equalSpacing
            stackView.alignment = .center
            containerView.addSubview(stackView)
            
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
            stackView.addArrangedSubview(imageView)
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.textAlignment = .center
            stackView.addArrangedSubview(label)
            
            switch headerSegmentedControl.selectedSegmentIndex {
            case 0:
                label.text = NSLocalizedString("You're favorite comics will show up here", comment: "")
                imageView.image = #imageLiteral(resourceName: "Favorite-Filled")
                break
            case 1:
                label.text = NSLocalizedString("Couldn't find any comics. Try reloading by pulling down", comment: "")
                break
            case 2:
                label.text = NSLocalizedString("You've read all the recent comics.\nYou'll have to wait for new ones", comment: "")
                imageView.image = #imageLiteral(resourceName: "AppIcon-NoPadding")
                break
            default: break
            }
            
            stackView.topAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerYAnchor, constant: -44).isActive = true
            stackView.leadingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.leadingAnchor).isActive = true
            stackView.trailingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.trailingAnchor).isActive = true
            
            tableView.backgroundView = containerView;
            tableView.separatorStyle = .none
        }
        else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
        
        return _dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: _comicCellIdentifier, for: indexPath) as! ComicTableViewCell
        
        cell.comic = _dataSource[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let comic = _dataSource[indexPath.row]
        
        let unreadTitle = !comic.isRead ? NSLocalizedString("Mark as\nread", comment: "") : NSLocalizedString("Mark as\nunread", comment: "")
        let unreadAction = UITableViewRowAction(style: .normal, title: unreadTitle, handler: {
            _,_ in
            DataService.instance.setComic(comic, asRead: !comic.isRead)
        })
        unreadAction.backgroundColor = UIColor.blue

        let favoriteTitle = !comic.isFavorite ? NSLocalizedString("Mark as\nfavorite", comment: "") : NSLocalizedString("Remove as\nfavorite", comment: "")
        let favoriteAction = UITableViewRowAction(style: .normal, title: favoriteTitle, handler: {
            _,_ in
            DataService.instance.setComic(comic, asFavorite: !comic.isFavorite)
        })
        
        return [unreadAction, favoriteAction]
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {}
}
