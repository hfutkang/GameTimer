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
    
    @IBOutlet weak var fbLoginButton: UIButton!
    
    @IBOutlet weak var gpLoginButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if FBSDKAccessToken.current() != nil {
            print("current login \(FBSDKAccessToken.current().userID)\n")
        } else {
            print("current not login\n")
        }
        GIDSignIn.sharedInstance().s
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
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
    
    //#MARK GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
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
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        print("sign in will dispathc\n")
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
}
