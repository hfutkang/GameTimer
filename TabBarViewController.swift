//
//  NavigationViewController.swift
//  GameTimer
//
//  Created by devel on 16/9/23.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import UIKit
class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        print("viewDidLoad\n")
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 20/255.0, green: 23/255.0, blue: 35/255.0, alpha: 1)
    }
    
    override func didReceiveMemoryWarning() {
        
    }
}
