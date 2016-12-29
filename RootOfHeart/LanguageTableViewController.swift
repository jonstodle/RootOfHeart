//
//  LanguageTableViewController.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 22/12/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class LanguageTableViewController: UITableViewController {
    
    // MARK: - Implementation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Language", comment: "")
        
        let currentLocale = NSLocale(localeIdentifier: Bundle.main.preferredLocalizations.first!)
        for localization in Bundle.main.localizations {
            if let displayName = currentLocale.displayName(forKey: .identifier, value: localization)?.localizedCapitalized {
                languages.append(Language(displayName: displayName, code: localization))
            }
        }
        languages.sort(by: { $0.displayName < $1.displayName })
        languages.insert(Language(displayName: NSLocalizedString("System", comment: ""), code: ""), at: 0)
        
        tableView.rx
            .itemDeselected
            .subscribe(onNext: {
                [unowned self] indexPath in
                self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
            })
            .addDisposableTo(_disposeBag)
        
        tableView.rx
            .itemSelected
            .subscribe(onNext: {
                [unowned self] indexPath in
                self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                let language = self.languages[indexPath.row]
                StateService.instance.languageOverride.value = language.code
                
                if StateService.instance.languageOverride.value != self.currentLanguageOverride
                    && !self.hasShownWarning{
                    self.hasShownWarning = true
                    let alert = UIAlertController(title: NSLocalizedString("Changing language", comment: "Used in alert when changing language in app settings"), message: NSLocalizedString("The app needs to exit and be launched again to change language", comment: ""), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Exit now", comment: ""), style: .destructive, handler: { _ in exit(0) }))
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Later", comment: ""), style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
            .addDisposableTo(_disposeBag)
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
        return languages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Basic", for: indexPath)
        
        cell.textLabel?.text = languages[indexPath.row].displayName
        
        if languages[indexPath.row].code == StateService.instance.languageOverride.value {
            cell.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        else { cell.accessoryType = .none }
        
        return cell
    }
    
    
    
    // MARK: - Private Properites
    
    private let currentLanguageOverride = StateService.instance.languageOverride.value
    private var hasShownWarning = false
    private var languages = [Language]()
    private let _disposeBag = DisposeBag()
}
