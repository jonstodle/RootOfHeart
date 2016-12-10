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

class LaunchViewTableViewController: UITableViewController {
    
    // MARK: - Private Properties
    
    private let _disposeBag = DisposeBag()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        tableView.rx
            .itemDeselected
            .subscribe(onNext: {
                indexPath in
                self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
            })
            .addDisposableTo(_disposeBag)

        tableView.rx
            .itemSelected
            .subscribe(onNext: {
                indexPath in
                self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                SettingsService.launchView = LaunchView(rawValue: indexPath.row)!
                _ = self.navigationController?.popViewController(animated: true)
            })
            .addDisposableTo(_disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.cellForRow(at: IndexPath(row: SettingsService.launchView.rawValue, section: 0))?.accessoryType = .checkmark
    }
}
