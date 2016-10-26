//
//  ScoreboardViewController.swift
//  GameTimer
//
//  Created by devel on 16/10/24.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import Foundation
import UIKit
class ScoreboardViewController: UIViewController, GCDAsyncUdpSocketDelegate {
    
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
        
        //初始化upd socket
        initUdpSocket()
        
        //根据屏幕方向加载view
        initScoreboardView()
        
        //监听屏幕方向变化
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarOrientationChanged(sender:)), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        
    }
    
    @objc func statusBarOrientationChanged(sender: Notification) {
        print("statusBarOrientationChanged \(UIApplication.shared.statusBarOrientation)\n")
        let orientation = UIApplication.shared.statusBarOrientation
        if orientation != .landscapeLeft && orientation != .landscapeRight && orientation != .portrait {
            return
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        self.viewDidLoad()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.enableLandscape = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.enableLandscape = false
    }
    
    //初始化scoreboard
    func initScoreboardView() {
        
        let orientation = UIApplication.shared.statusBarOrientation
        if orientation == .landscapeRight || orientation == .landscapeLeft {
            print("orientation landscape\n")
            if scoreboardView != nil {
                scoreboardView.removeFromSuperview()
            }
            let nib = Bundle.main.loadNibNamed("ScoreboardViewHorizontal", owner: nil, options: nil)
            scoreboardView = nib?[0] as! ScoreboardView
            
            self.tabBarController?.tabBar.isHidden = true
            
        } else if orientation == .portrait {
            print("orientation portrait\n")
            if scoreboardView != nil {
                scoreboardView.removeFromSuperview()
            }
            let nib = Bundle.main.loadNibNamed("ScoreboardViewVertical", owner: nil, options: nil)
            scoreboardView = nib?[0] as! ScoreboardView
            self.tabBarController?.tabBar.isHidden = false
        } else {
            return
        }
        
        scoreboardView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scoreboardView)
        
        self.view.addConstraint(NSLayoutConstraint(item:scoreboardView, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: scoreboardView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: scoreboardView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: scoreboardView, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top , multiplier: 1, constant: 0))
        
        //初始化timerPicker元素数组
        scoreboardView.initTimerPickerComponents()
        scoreboardView.controller = self
        scoreboardView.initLabelFontSize()
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
            let data = "{\"button\":}\(cmd)"
            TcpConnection.sharedInstance.send(data: data.data(using: .utf8)!, tag: 0)
        } else {
            print("tcp disconnected\n")
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
