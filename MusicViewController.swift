//
//  MuiscViewController.swift
//  GameTimer
//
//  Created by devel on 16/9/14.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class MusicViewController: UIViewController {
    
    //#MARK Attributes
    var player:MPMusicPlayerController! = nil
    
    //#MARK Outlets
    
    @IBOutlet weak var accessView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("MuiscViewController viewDidLoad\n")
        initMPPlayer()
        
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 20/255.0, green: 23/255.0, blue: 35/255.0, alpha: 1)
        
        self.tabBarController?.tabBar.isTranslucent = false
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 20/255.0, green: 23/255.0, blue: 35/255.0, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        accessView.isHidden = ModeCheckUtils.canPlayMusic()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openiTunes(_ sender: UIButton) {
        let url = URL(string:"music:")
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            print("1111111\n")
        }
    }
    
    @IBAction func play(_ sender: UIButton) {
        if player.playbackState != .playing {
            player.play()
        } else {
            player.pause()
        }
    }
    
    @IBAction func previous(_ sender: UIButton) {
        player.skipToPreviousItem()
    }
    @IBAction func next(_ sender: UIButton) {
        
        player.skipToNextItem()
    }
    @objc func onReceiveNotification(notification:Notification) ->Void {
        if notification.name == .MPMusicPlayerControllerPlaybackStateDidChange {
            switch player.playbackState {
            case .paused:
                print("music paused\n")
            case .playing:
                print("music playing\n")
                
            case .stopped:
                print("music stopped\n")
            default:
                break
            }
        } else if notification.name == .MPMusicPlayerControllerNowPlayingItemDidChange {
            print("now playing item change\n")
        }
    }
    
    func initMPPlayer() {
        player = MPMusicPlayerController.systemMusicPlayer()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(onReceiveNotification(notification:)), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: player)
        notificationCenter.addObserver(self, selector: #selector(onReceiveNotification(notification:)), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: player)
        player.beginGeneratingPlaybackNotifications()
    }

}
