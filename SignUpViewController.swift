//
//  SignUpViewController.swift
//  GameTimer
//
//  Created by devel on 16/10/18.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import UIKit
class SignUpViewController:UIViewController {
    
    //MARK Outlet
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    
    @IBOutlet weak var createAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SignUpViewController viewDidLoad\n")
        
        initViewStatus()
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 20/255.0, green: 23/255.0, blue: 35/255.0, alpha: 1)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func initViewStatus() -> Void {
        
        let view1 = UIImageView(image: UIImage(named: "icon_lastname"))
        let view2 = UIImageView(image: UIImage(named: "icon_lastname"))
        let view3 = UIImageView(image: UIImage(named: "icon_email"))
        let view4 = UIImageView(image: UIImage(named: "icon_password"))
        let view5 = UIImageView(image: UIImage(named: "icon_password"))
        
        firstNameTextField.leftViewMode = .always
        firstNameTextField.leftView = view1
        
        lastNameTextField.leftViewMode = .always
        lastNameTextField.leftView = view2
        
        emailTextField.leftViewMode = .always
        emailTextField.leftView = view3
        
        passwordTextField.leftViewMode = .always
        passwordTextField.leftView = view4
        
        confirmTextField.leftViewMode = .always
        confirmTextField.leftView = view5
        
        createAccountButton.layer.cornerRadius = 10.0
        
    }
    
}
