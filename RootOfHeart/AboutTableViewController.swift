//
//  AboutTableViewController.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 10/12/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import UIKit

class AboutTableViewController: UITableViewController {
    
    // MARK: - Outlets

    @IBOutlet weak var headerLabel: UILabel!
    
    
    
    // MARK: - Private Properties
    
    private var translators: NSArray = []
    
    private let textInSection0 = [Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String]
    
    private let textInSection1 = ["Jon Stødle"]
    
    private let textInSection2 = [
        NSLocalizedString("Without the help of these libraries, making this app would be a lot harder", comment: ""),
        "Alamofire",
        "DateSwift",
        "Kingfisher",
        "Realm",
        "RxSwift",
        "SwiftyJSON"
    ]
    
    private let textInSection3 = ["Icons8"]
    
    private var currentLocale = NSLocale(localeIdentifier: Bundle.main.preferredLocalizations.first!)
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerLabel.text = NSLocalizedString("Thanks for downloading √♥︎", comment: "")
        
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
        case 0: return NSLocalizedString("Version", comment: "")
        case 1: return NSLocalizedString("Developer", comment: "")
        case 2: return NSLocalizedString("Libraries", comment: "")
        case 3: return NSLocalizedString("Icons", comment: "")
        case 4: return NSLocalizedString("Translators", comment: "")
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return textInSection0.count
        case 1: return textInSection1.count
        case 2: return textInSection2.count
        case 3: return textInSection3.count
        case 4: return translators.count + 1
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
            if indexPath.row == translators.count {
                let cell = getLinkButtonCell()
                cell.linkButton.setTitle(NSLocalizedString("Help translate", comment: ""), for: .normal)
                cell.link = "https://poeditor.com/join/project/d30Zf6wupR"
                return cell
            }
            else {
            let cell = getRightDetailCell()
            let translator = translators[indexPath.row] as! NSDictionary
            cell.detailTextLabel?.text = translator["Name"] as? String
            cell.textLabel?.text = currentLocale.displayName(forKey: .identifier, value: translator["Language"]!)?.localizedCapitalized
            
            return cell
            }
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
    private func getLinkButtonCell() -> LinkButtonTableViewCell { return tableView.dequeueReusableCell(withIdentifier: "LinkButton") as! LinkButtonTableViewCell }
}
