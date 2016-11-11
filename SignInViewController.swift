//
//  SignInViewController.swift
//  GameTimer
//
//  Created by devel on 16/10/18.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import UIKit
class SignInViewController:UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    //MARK Outlet
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var siginButton: UIButton!
    
    @IBOutlet weak var fbLoginButton: UIButton!
    
    @IBOutlet weak var gpLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SignInViewController viewDidLoad\n")
        if FBSDKAccessToken.current() != nil {
            print("current login \(FBSDKAccessToken.current().userID)\n")
        } else {
            print("current not login\n")
        }
        
        initViewStatus()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        //设置导航栏背景颜色
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 20/255.0, green: 23/255.0, blue: 35/255.0, alpha: 1)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func initViewStatus() -> Void {
        let imageView1 = UIImageView(image: UIImage(named: "icon_email"))
        
        let imageView2 = UIImageView(image: UIImage(named: "icon_password"))
        
        emailTextField.leftViewMode = .always
        emailTextField.leftView = imageView1
        
        passwordTextField.leftViewMode = .always
        passwordTextField.leftView = imageView2
        
        siginButton.layer.cornerRadius = 10
        
    }
    
    //MARK Actions
    @IBAction func loginFacebook(_ sender: UIButton) {
        let loginManager = FBSDKLoginManager()
        loginManager.loginBehavior = .systemAccount
        loginManager.logIn(withPublishPermissions: [], from: self, handler: {(result: FBSDKLoginManagerLoginResult?, error:Error?) -> Void in
            if let e = error {
                print("login error \(e)\n")
            } else if (result?.isCancelled)! {
                print("login canceled\n")
            } else {
                print("login success \(result?.token.tokenString) \(result?.token.userID)\n")
                //performSegue(withIdentifier: "loginSegue", sender: loginButton)
            }
        })
    }
    
    @IBAction func siginGoogle(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    //#MARK GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print("didSignInFor\n")
        if error == nil {
            print("didSignInFor \(user.userID) \(user.profile.name)\n")
        } else {
            print("google sigin error\n")
        }
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
        if error == nil {
            print("didDisconnectWith \(user.userID) \(user.profile.name)\n")
        } else {
            print("google didDisconnect error\n")
        }
    }
    
    //#MARK GIDSignInUIDelegate
    /*func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        print("sign in will dispathc\n")
        
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        print("signIn dismiss\n")
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        print("signIn present viewController\n")
        self.present(viewController, animated: true, completion: nil)
    }*/
    
}
