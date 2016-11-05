//
//  HomeViewController.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 27/10/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import UIKit
import RxSwift

class HomeViewController: UITableViewController {
    
    private let cellIdentifier = "default"
    
    private var comics = [Comic]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        title = "√♥︎"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        _ = XkcdClient.get(comics: Array(1337...1345))
            .subscribe(
                onNext: { x in
                    if let comic = x{
                        let ip = IndexPath(row: self.comics.count, section: 0)
                        self.comics.append(comic)
                        self.tableView.insertRows(at: [ip], with: .bottom)
                    }
                },
                onError: nil,
                onCompleted: nil,
                onDisposed: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return comics.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        cell.textLabel?.text = comics[indexPath.row].title
        
        return cell
    }
}
