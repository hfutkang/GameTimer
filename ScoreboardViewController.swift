//
//  ScoreboardViewController.swift
//  GameTimer
//
//  Created by devel on 16/10/24.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import Foundation
import UIKit
class ScoreboardViewController: UIViewController, GCDAsyncUdpSocketDelegate, UIImagePickerControllerDelegate {
    
    //#MARK Attributes
    var hours:[String]!
    var minutes:[String]!
    var seconds:[String]!
    
    let periodNames = ["PERIOD", "HALF", "QUARTER", "INNING", "SET", "ROUND"]
    
    var hour = 0
    var minute = 0
    var second = 0
    
    var periodName = "PERIOD"
    
    var mUdpSocket:GCDAsyncUdpSocket!
    
    var scoreboardView:ScoreboardView!
    
    var willShowImagePicker = false//打开图库页面支持横竖屏
    
    var verticalView:ScoreboardView!
    var horizontalView:ScoreboardView!
    
    //MARK Outlets
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var periodNameLabel: UILabel!
    
    @IBOutlet weak var homeImage: UIImageView!
    @IBOutlet weak var guestImage: UIImageView!
    @IBOutlet weak var homeNameLabel: UILabel!
    @IBOutlet weak var guestNameLabel: UILabel!
    
    @IBOutlet weak var homeScoreLabel: UILabel!
    @IBOutlet weak var guestScoreLabel: UILabel!
    
    @IBOutlet weak var homePoss: UIButton!
    @IBOutlet weak var guestPoos: UIButton!
    @IBOutlet weak var homeBonus: UIButton!
    @IBOutlet weak var guestBonus: UIButton!
    
    @IBOutlet weak var buzzerButton: UIButton!
    
    //MARK Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ScoreboardViewController viewDidLoad\n")
        
        //初始化upd socket
        initUdpSocket()
        
        //根据屏幕方向加载view
        initScoreboardView()
        
        //监听屏幕方向变化
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarOrientationChanged(sender:)), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connectStatusChanged(sender:)), name: NSNotification.Name(rawValue: "sctek.cn.MGameTimer.connectStateChanged"), object: nil)
        
        //设置tab bar背景
        self.tabBarController?.tabBar.isTranslucent = false
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 20/255.0, green: 23/255.0, blue: 35/255.0, alpha: 1)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.enableLandscape = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !willShowImagePicker {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.enableLandscape = false
        }
    }
    
    //初始化scoreboard
    func initScoreboardView() {
        
        let orientation = UIApplication.shared.statusBarOrientation
        if orientation == .landscapeRight || orientation == .landscapeLeft {
            print("orientation landscape\n")
            if verticalView != nil {
                verticalView.removeFromSuperview()
            }
            if horizontalView == nil {
                let nib = Bundle.main.loadNibNamed("ScoreboardViewHorizontal", owner: nil, options: nil)
                horizontalView = nib?[0] as! ScoreboardView
                horizontalView.initTimerPickerComponents()
                horizontalView.controller = self
                horizontalView.initLabelFontSize()
            }
            scoreboardView = horizontalView
            self.tabBarController?.tabBar.isHidden = true
            scoreboardView.initViewStatus(sourceView: verticalView)
        } else if orientation == .portrait {
            print("orientation portrait\n")
            if horizontalView != nil {
                horizontalView.removeFromSuperview()
            }
            
            if verticalView == nil {
                let nib = Bundle.main.loadNibNamed("ScoreboardViewVertical", owner: nil, options: nil)
                verticalView = nib?[0] as! ScoreboardView
                verticalView.initTimerPickerComponents()
                verticalView.controller = self
                verticalView.initLabelFontSize()
            }
            scoreboardView = verticalView
            self.tabBarController?.tabBar.isHidden = false
            scoreboardView.initViewStatus(sourceView: horizontalView)
        } else {
            return
        }
        
        scoreboardView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scoreboardView)
        
        self.view.addConstraint(NSLayoutConstraint(item:scoreboardView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 20))
        self.view.addConstraint(NSLayoutConstraint(item: scoreboardView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: scoreboardView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: scoreboardView, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top , multiplier: 1, constant: 0))
        
    }
    
    //初始化udp接口
    func initUdpSocket() {
        if mUdpSocket != nil {
            return
        }
        mUdpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try mUdpSocket.bind(toPort: 7071)
            try mUdpSocket.enableBroadcast(true)
            try mUdpSocket.beginReceiving()
        } catch {
            print("init udpSocket error \(error)\n")
        }
    }
    
    //通过Tcp发送命令数据
    func sendData(cmd: UInt8) {
        if TcpConnection.sharedInstance.isConnected() {
            let data = "{\"cmd\":\"button\",\"value\":\"\(cmd)\"}"
            TcpConnection.sharedInstance.send(data: data.data(using: .utf8)!, tag: 0)
        } else {
            print("tcp disconnected\n")
        }
    }
    
    //MARK Objc
    @objc func statusBarOrientationChanged(sender: Notification) {
        print("statusBarOrientationChanged \(UIApplication.shared.statusBarOrientation)\n")
        let orientation = UIApplication.shared.statusBarOrientation
        if orientation != .landscapeLeft && orientation != .landscapeRight && orientation != .portrait {
            return
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "sctek.cn.MGameTimer.connectStateChanged"), object: nil)
        self.viewDidLoad()
    }
    
    @objc func connectStatusChanged(sender:Notification) {
        print("connectStatusChanged\n")
        let state = sender.userInfo?["state"] as! String
        if state == "connected" {
            scoreboardView.connectStatusButton.isSelected = true
            scoreboardView.connectStatusButton.setTitle("Connected", for: .normal)
        } else if state == "disconnected" {
            scoreboardView.connectStatusButton.isSelected = false
            scoreboardView.connectStatusButton.setTitle("Disconnected", for: .normal)
        }
    }

    
    //MARK GCDAsyncUdpSocketDelegate
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        var json:[String:Any]! = nil
        do {
            try json = JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
        } catch {
            
        }
        let data = ScoreboardData(json:json)
        scoreboardView.updateUI(data: data!)
    }
    
}
