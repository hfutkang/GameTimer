//
//  NavigationViewController.swift
//  GameTimer
//
//  Created by devel on 16/9/23.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import UIKit
class NavigationController: UINavigationController {
    override func viewDidLoad() {
        print("viewDidLoad\n")
        SFXViewController()
        TableViewController()
    }
    
    override func didReceiveMemoryWarning() {
        
    }
}
