//
//  SettingsTabsViewController.swift
//  RootOfHeart
//
//  Created by Jon Stødle on 21/12/2016.
//  Copyright © 2016 Jon Stødle. All rights reserved.
//

import UIKit

class SettingsTabsViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "√♥︎"
        tabBar.items![0].title = NSLocalizedString("Settings", comment: "")
        tabBar.items![1].title = NSLocalizedString("About", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
