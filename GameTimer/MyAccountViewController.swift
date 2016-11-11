//
//  MyAccountViewController.swift
//  GameTimer
//
//  Created by devel on 16/11/4.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import Foundation
import UIKit
class MyAccountViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("MyAccountViewController viewDidLoad\n")
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 20/255.0, green: 23/255.0, blue: 35/255.0, alpha: 1)
        
    }
}
