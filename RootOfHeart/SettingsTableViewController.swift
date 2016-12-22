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
    
    @IBOutlet weak var launchViewTitleLabel: UILabel!
    @IBOutlet weak var launchViewChoiceLabel: UILabel!
    @IBOutlet weak var languageTitleLabel: UILabel!
    @IBOutlet weak var languageChoiceLabel: UILabel!
    
    
    
    // MARK: - Private Properties
    
    private let _disposeBag = DisposeBag()
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        launchViewTitleLabel.text = NSLocalizedString("Launch view", comment: "")
        languageTitleLabel.text = NSLocalizedString("Language", comment: "")

        tableView.rx
            .itemSelected
            .subscribe(onNext: {
                [weak self] indexPath in
                var newVc = UIViewController()
                
                switch indexPath.row {
                case 0: newVc = self!.storyboard!.instantiateViewController(withIdentifier: "LaunchViewTableViewController") as! LaunchViewTableViewController; break
                case 1: newVc = self!.storyboard!.instantiateViewController(withIdentifier: "LanguageTableViewController") as! LanguageTableViewController; break
                default: return
                }
                
                
                self!.navigationController?.pushViewController(newVc, animated: true)
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
        languageChoiceLabel.text = getCurrentLanguage()
    }
    
    
    
    // MARK: - Helper Methods
    
    private func getCurrentLanguage() -> String? { return NSLocale(localeIdentifier: Bundle.main.preferredLocalizations.first!).displayName(forKey: .identifier, value: !SettingsService.languageOverride.isEmpty ? SettingsService.languageOverride : Bundle.main.preferredLocalizations.first!)?.localizedCapitalized }
}
