//
//  AboutTableViewController.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 10/12/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import UIKit

class AboutTableViewController: UITableViewController {
    
    // MARK: - Private Properties
    
    private var translators: NSArray = []
    
    private let textInSection0 = [Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String]
    
    private let textInSection1 = ["Jon Stødle"]
    
    private let textInSection2 = [
        "Without the help of these libraries, making this app would be a lot harder".localized,
        "Alamofire",
        "DateSeift",
        "Kingfisher",
        "Realm",
        "RxSwift",
        "SwiftyJSON"
    ]
    
    private let textInSection3 = ["Icons8"]
    
    private var currentLocale = NSLocale(localeIdentifier: Bundle.main.preferredLocalizations.first!)
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let translatorsPath = Bundle.main.path(forResource: "Translators", ofType: "plist")
        translators = NSArray(contentsOfFile: translatorsPath!)!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Version".localized
        case 1: return "Developer".localized
        case 2: return "Libraries".localized
        case 3: return "Icons".localized
        case 4: return "Translators".localized
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return textInSection0.count
        case 1: return textInSection1.count
        case 2: return textInSection2.count
        case 3: return textInSection3.count
        case 4: return translators.count
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = getBasicCell()
            cell.textLabel?.text = textInSection0[indexPath.row]
            return cell
        case 1:
            let cell = getBasicCell()
            cell.textLabel?.text = textInSection1[indexPath.row]
            return cell
        case 2:
            var cell: UITableViewCell
            
            if indexPath.row == 0 { cell = getBasicInfoCell() }
            else { cell = getBasicCell() }
            
            cell.textLabel?.text = textInSection2[indexPath.row]
            return cell
        case 3:
            let cell = getBasicCell()
            cell.textLabel?.text = textInSection3[indexPath.row]
            return cell
        case 4:
            let cell = getRightDetailCell()
            let translator = translators[indexPath.row] as! NSDictionary
            cell.detailTextLabel?.text = translator["Name"] as? String
            cell.textLabel?.text = currentLocale.displayName(forKey: .identifier, value: translator["Language"]!)
            
            return cell
        default:
            return tableView.dequeueReusableCell(withIdentifier: "Basic")!
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == tableView.numberOfSections - 1 ? bottomLayoutGuide.length : 0
    }
    
    
    
    // MARK: - Helper Methods
    
    private func getBasicCell() -> UITableViewCell { return tableView.dequeueReusableCell(withIdentifier: "Basic")! }
    private func getSubtitleCell() -> UITableViewCell { return tableView.dequeueReusableCell(withIdentifier: "Subtitle")! }
    private func getBasicInfoCell() -> UITableViewCell { return tableView.dequeueReusableCell(withIdentifier: "BasicInfo")! }
    private func getRightDetailCell() -> UITableViewCell { return tableView.dequeueReusableCell(withIdentifier: "RightDetail")! }
}
