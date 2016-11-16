//
//  AppDelegate.swift
//  GameTimer
//
//  Created by devel on 16/9/13.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GCDAsyncSocketDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    var enableLandscape = false//是否允许横屏
    
    var privilegeMask:UInt8 = 0x00//是否是主控
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        print("didFinishLaunchingWithOptions \(UIDevice.current.name)\n")
        
        application.setStatusBarStyle(.lightContent, animated: true)
        
        initNotificationCenter()
        
        //For tcp connection
        let tcpConnection = TcpConnection.sharedInstance
        tcpConnection.setDelegate(delegate: self)
        //tcpConnection.connect(host: "192.168.5.120", port: 0x8888)
        
        //init default sound effect
        _initDefaultSound()
        
        //Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //Google
        GIDSignIn.sharedInstance().clientID = "370896725852-q3jaeuuqphrqdfupslrac15p88jpiu8n.apps.googleusercontent.com"
        
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
    }/**/
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)||GIDSignIn.sharedInstance().handle(url, sourceApplication: options[.sourceApplication] as! String, annotation: options[.annotation])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        print("open url:\(url)\n")
        let result = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) || GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
        print("open url \(result)\n")
        return result
    }
    
    //UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping()  -> Void) {
        print("didReceive response\n")
        let notification = Notification.init(name: NSNotification.Name("sctek.cn.MGameTimer.newUser"), object: nil, userInfo: response.notification.request.content.userInfo)
        NotificationCenter.default.post(notification)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping(UNNotificationPresentationOptions) -> Void) {
        print("willPresent notification\n")
        
    }
    
    //#MARK AsncySockeDelegate
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("didConnectToHost \(host) \(port)\n")
        let notification = Notification.init(name: NSNotification.Name(rawValue: "sctek.cn.MGameTimer.connectStateChanged"), object: nil, userInfo: ["state":"connected"])
        NotificationCenter.default.post(notification)
        TcpConnection.sharedInstance.send(cmd: "join", value: UIDevice.current.name, extra: nil)
        sock.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("didRead \(String(data: data, encoding: .utf8)) \(tag)\n)")
        sock.readData(withTimeout: -1, tag: tag)//让App一值保持等待读的状态。
         do {
            let msg = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
            let result = msg["cmd"] as! String
            switch result {
            case "mic":
                if tag == 0 {
                    let res = msg["res"] as! String
                    let notification = Notification.init(name: NSNotification.Name(rawValue: "sctek.cn.MGameTimer.mic"), object: nil, userInfo: ["result":res])
                    NotificationCenter.default.post(notification)
                }
                break
            case "idlist":
                let ssid = msg["ssid"] as! String
                let idlist = msg["ids"]
                let notification = Notification.init(name: NSNotification.Name("sctek.cn.MGameTimer.idlist"), object: nil, userInfo: ["idlist":idlist, "ssid":ssid])
                NotificationCenter.default.post(notification)
                break
            case "name":
                let name = msg["value"] as! String
                if UIApplication.shared.applicationState == .active {
                    let notification = Notification.init(name: NSNotification.Name(rawValue: "sctek.cn.MGameTimer.newUser"), object: nil, userInfo: ["name":name])
                    NotificationCenter.default.post(notification)
                } else {
                    addLocalNotification(userName: name)
                }
                break
            case "mod":
                let mode = msg["value"] as! Int
                privilegeMask = UInt8(mode)
                let notification = Notification.init(name: NSNotification.Name("sctek.cn.MGameTimer.modeChanged"), object: nil, userInfo: ["mode":privilegeMask])
                NotificationCenter.default.post(notification)
                break
            case "getLevel":
                let level = msg["res"] as! Int
                let notification = Notification.init(name: NSNotification.Name("sctek.cn.MGameTimer.brightnessLevel"), object: nil, userInfo: ["level":level])
                NotificationCenter.default.post(notification)
            case "soundStatus":
                let notification = Notification.init(name: NSNotification.Name("sctek.cn.MGameTimer.soundStatus"), object: nil, userInfo: ["buzzer":msg["buzzer"], "mute":msg["buzzer"]])
                NotificationCenter.default.post(notification)
            default:
                break
            }
         } catch {
            print("read data error \(error)\n")
         }
        
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("socketDidDisconnect\n")
        let notification = Notification.init(name: NSNotification.Name(rawValue: "sctek.cn.MGameTimer.connectStateChanged"), object: nil, userInfo: ["state":"disconnected"])
        NotificationCenter.default.post(notification)
        privilegeMask = 0x00
        let notification1 = Notification.init(name: NSNotification.Name("sctek.cn.MGameTimer.modeChanged"), object: nil, userInfo: ["mode":privilegeMask])
        NotificationCenter.default.post(notification1)
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
    
    func _initStatusBar() {
        //设置导航栏背景颜色
        
    }
    
    func initNotificationCenter() -> Void {
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge,.carPlay]){(granted,error) in}
        
        let category = UNNotificationCategory(identifier: "sctek.cn.MGameTimer.newUser", actions: [], intentIdentifiers: [], options: [.customDismissAction])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    func addLocalNotification(userName: String) -> Void {
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.body = userName + " is syncing with GameTimer";
        content.userInfo = ["name": userName]
        content.categoryIdentifier = "sctek.cn.MGameTimer.newUser"
        
        content.sound = UNNotificationSound.default()
        
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }

}

