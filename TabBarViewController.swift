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
        print("TabBarViewController viewDidLoad\n")
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 20/255.0, green: 23/255.0, blue: 35/255.0, alpha: 1)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNewUserIn(sender:)), name: NSNotification.Name("sctek.cn.MGameTimer.newUser"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onModeChanged(sender:)), name: NSNotification.Name("sctek.cn.MGameTimer.modeChanged"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
    //MARK objcs
    @objc func onNewUserIn(sender: Notification) {
        print("onNewUserIn\n")
        let name = sender.userInfo?["name"] as! String
        let alert = UIAlertController(title: "New User", message: name + " wants to Connect to GAMETIMER SCOREBOARD?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Deny", style: .default, handler: {_ in
            print("deny\n")
        }))
        alert.addAction(UIAlertAction(title: "Allow", style: .default, handler: {_ in
            self.selectedIndex = 4
            let navViewController = self.viewControllers?[4] as! UINavigationController
            let menuViewController = navViewController.viewControllers[0] as! MenuViewController
            menuViewController.performSegue(withIdentifier: "connectedDevices", sender: menuViewController)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func onModeChanged(sender: Notification) -> Void {
        
        let selectedView = self.viewControllers?[selectedIndex]
        switch selectedIndex {
        case 1:
            let view = (selectedView as! UINavigationController).viewControllers[0] as! SFXViewController
            view.accessView.isHidden = ModeCheckUtils.canPlaySFX()
            break
        case 2:
            let view = (selectedView as! UINavigationController).viewControllers[0] as! MicroViewController
            view.accessView.isHidden = ModeCheckUtils.canControlMic()
            break
        case 3:
            let view = (selectedView as! UINavigationController).viewControllers[0] as! MusicViewController
            view.accessView.isHidden = ModeCheckUtils.canPlayMusic()
        default:
            break
        }
    }
}
