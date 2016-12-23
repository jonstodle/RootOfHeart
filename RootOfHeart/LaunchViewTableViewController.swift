//
//  LaunchViewTableViewController.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 10/12/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class LaunchViewTableViewController: UITableViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var favoritesLabel: UILabel!
    @IBOutlet weak var allLabel: UILabel!
    @IBOutlet weak var unreadLabel: UILabel!
    
    
    
    // MARK: - Private Properties
    
    private let _disposeBag = DisposeBag()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Launch view", comment: "")
        favoritesLabel.text = NSLocalizedString("Favorites", comment: "")
        allLabel.text = NSLocalizedString("All", comment: "")
        unreadLabel.text = NSLocalizedString("Unread", comment: "")
        
        tableView.rx
            .itemDeselected
            .subscribe(onNext: {
                [weak self] indexPath in
                self!.tableView.cellForRow(at: indexPath)?.accessoryType = .none
            })
            .addDisposableTo(_disposeBag)

        tableView.rx
            .itemSelected
            .subscribe(onNext: {
                [weak self] indexPath in
                self!.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                StateService.instance.launchView.value = LaunchView(rawValue: indexPath.row)!
                _ = self!.navigationController?.popViewController(animated: true)
            })
            .addDisposableTo(_disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.cellForRow(at: IndexPath(row: StateService.instance.launchView.value.rawValue, section: 0))?.accessoryType = .checkmark
    }
}
