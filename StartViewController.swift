//
//  StartViewController.swift
//  GameTimer
//
//  Created by devel on 16/11/10.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import Foundation
import UIKit
class StartViewController: UIViewController {
    
    @IBOutlet weak var getStartButton: UIButton!
    
    @IBOutlet weak var signInButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        
        getStartButton.layer.cornerRadius = 10
        getStartButton.layer.borderWidth = 1.0
        
        signInButton.layer.cornerRadius = 10
        signInButton.layer.borderWidth = 1.0
    }
    
    @IBAction func unWindToStartView(sender: UIStoryboardSegue) {
        print("unWindToStartView\n")
    }
}
