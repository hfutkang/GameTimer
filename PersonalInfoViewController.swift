//
//  PersonalInfoViewController.swift
//  GameTimer
//
//  Created by devel on 16/10/18.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import UIKit
class PersonalInfoViewController:UIViewController {
    
    //MARK Outlet
    @IBOutlet var ageLabel: UIView!
    @IBOutlet var countryLabel: UIView!
    @IBOutlet var genderLabel: UIView!
    @IBOutlet var sportsLabel: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置导航栏背景颜色
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 16/255.0, green: 18/255.0, blue: 26/255.0, alpha: 1)
    }
}
