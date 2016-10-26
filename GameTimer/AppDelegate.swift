//
//  AppDelegate.swift
//  GameTimer
//
//  Created by devel on 16/9/13.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GCDAsyncSocketDelegate {

    var window: UIWindow?
    var enableLandscape = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        print("didFinishLaunchingWithOptions\n")
        
        //For tcp connection
        let tcpConnection = TcpConnection.sharedInstance
        tcpConnection.setDelegate(delegate: self)
        tcpConnection.connect(host: "192.168.222.254", port: 3212)
        
        //init default sound effect
        _initDefaultSound()
        
        //Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //Google
        print("11111\n")
        GIDSignIn.sharedInstance().clientID = "370896725852-q3jaeuuqphrqdfupslrac15p88jpiu8n.apps.googleusercontent.com"
        print("2222222\n")
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if enableLandscape {
            return .allButUpsideDown
        }
        return .portrait
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)||GIDSignIn.sharedInstance().handle(url, sourceApplication: options[.sourceApplication] as! String, annotation: options[.annotation])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) || GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    //#MARK AsncySockeDelegate
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("didConnectToHost \(host) \(port)\n")
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("socketDidDisconnect\n")
    }
    
    func _initDefaultSound() -> Void {
        let path = Bundle.main.path(forResource: "defaultSoundList", ofType: "plist")
        let sounds = NSDictionary(contentsOfFile: path!)
        let temp = sounds as! [String : String]
        var urls = [String : URL]()
        for (key, value) in temp {
            let url = Bundle.main.url(forResource: value, withExtension: "mp3", subdirectory: "SFX")
            urls[key] = url
        }
        UserDefaults.standard.register(defaults: urls)
    }

}

