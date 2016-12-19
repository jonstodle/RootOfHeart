//
//  SettingsTableViewController.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 10/12/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingsTableViewController: UITableViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var launchViewChoiceLabel: UILabel!
    @IBOutlet weak var languageChoiceLabel: UILabel!
    
    
    
    // MARK: - Private Properties
    
    private let _disposeBag = DisposeBag()
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        launchViewChoiceLabel.text = SettingsService.launchView.stringValue

        tableView.rx
            .itemSelected
            .subscribe(onNext: {
                indexPath in
                var newVc = UIViewController()
                
                if indexPath.row == 0  { newVc = self.storyboard!.instantiateViewController(withIdentifier: "LaunchViewTableViewController") as! LaunchViewTableViewController }
                
                self.navigationController?.pushViewController(newVc, animated: true)
            })
            .addDisposableTo(_disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Implementation
    
    override func viewWillAppear(_ animated: Bool) {
        launchViewChoiceLabel.text = SettingsService.launchView.stringValue
    }
}
