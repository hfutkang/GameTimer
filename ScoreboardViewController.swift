//
//  ScoreboardViewController.swift
//  GameTimer
//
//  Created by devel on 16/10/24.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import Foundation
import UIKit
class ScoreboardViewController: UIViewController, GCDAsyncUdpSocketDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //#MARK Attributes
    var hours:[String]!
    var minutes:[String]!
    var seconds:[String]!
    
    let periodNames = ["PERIOD", "HALF", "QUARTER", "INNING", "SET", "ROUND"]
    
    var hour = 0
    var minute = 0
    var second = 0
    
    var periodName = "PERIOD"
    
    var udpSocket:GCDAsyncUdpSocket!
    
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
        homePoss.isSelected = false
        guestPoos.isSelected = false
        homeBonus.isSelected = false
        guestBonus.isSelected = false
        
        //初始化timerPicker元素数组
        initTimerPickerComponents()
        //初始化upd socket
        initUdpSocket()
    }
    
    //从Bundle中读出时间项
    func initTimerPickerComponents() {
        let dictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "timePickerList", ofType: "plist")!) as! [String:[String]]
        
        hours = dictionary["hour"]
        minutes = dictionary["minute"]
        seconds = dictionary["second"]
    }
    
    //初始化udp接口
    func initUdpSocket() {
        udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try udpSocket.bind(toPort: 7071)
            try udpSocket.enableBroadcast(true)
            try udpSocket.beginReceiving()
        } catch {
            print("init udpSocket error \(error)\n")
        }
    }
    
    //收到设备端广播后，更新UI显示
    func updateUI(data: ScoreboardData) {
        
        timeLabel.text = data.time
        periodLabel.text = "\(data.period)"
        homeScoreLabel.text = "\(data.hostScore)"
        guestScoreLabel.text = "\(data.guestScore)"
        switch data.bonus {
        case .guest:
            homeBonus.isSelected = false
            guestBonus.isSelected = true
        case .home:
            homeBonus.isSelected = true
            guestBonus.isSelected = false
        default:
            break;
        }
        switch data.poss {
        case .guest:
            homePoss.isSelected = false
            guestPoos.isSelected = true
        case .home:
            homePoss.isSelected = true
            guestPoos.isSelected = false
        default:
            break
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
    
    func showTimerPickerActionSheet() {
        let alert = UIAlertController(title: "Timer", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Timer", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Set Timer", style: .default, handler: {(_) in self.showTimerPickerDialog()}))
        alert.addAction(UIAlertAction(title: "Set Clock", style: .default, handler: {(_) in self.showTimerPickerDialog()}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showTimerPickerDialog() {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.restorationIdentifier = "time"
        
        let views = Bundle.main.loadNibNamed("DialogView", owner: nil, options: nil)
        let view = views?[0] as! AlterDialogView
        view.timePicker.dataSource = self
        view.timePicker.delegate = self
        
        view.timePicker.tag = 0
        
        view.okButton.addTarget(self, action: #selector(onOKButtonClicked(sender:)), for: .touchUpInside)
        view.cancelButton.addTarget(self, action: #selector(onCancelButtonClicked(sender:)), for: .touchUpInside)
        
        view.frame = alert.view.frame
        view.layer.cornerRadius = 6.0
        alert.view.addSubview(view)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showPeriodNamePickerDialog() {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.restorationIdentifier = "period"
        
        let views = Bundle.main.loadNibNamed("PeriodPickerView", owner: nil, options: nil)
        let view = views?[0] as! PeriodPickerView
        view.picker.dataSource = self
        view.picker.delegate = self
        
        view.picker.tag = 1
        
        view.confirm.addTarget(self, action: #selector(onCancelButtonClicked(sender:)), for: .touchUpInside)
        
        view.frame = alert.view.frame
        view.layer.cornerRadius = 6.0
        alert.view.addSubview(view)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK objc
    @objc func onCancelButtonClicked(sender:UIAlertController) {
        self.dismiss(animated: true, completion: nil)
        if sender.restorationIdentifier == "period" {
            periodNameLabel.text = periodName
        }
    }
    
    @objc func onOKButtonClicked(sender:UIAlertController) {
        
    }
    
    //MARK Actions
    @IBAction func onTimeLabelTapped(_ sender: UITapGestureRecognizer) {
        sendData(cmd: CommandCodes.CMD_TIMER_PLAY)
    }
    
    @IBAction func onTimeLabelLongpressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            showTimerPickerActionSheet()
        }
    }
    @IBAction func onHomeImageTapped(_ sender: UITapGestureRecognizer) {
    }
    
    @IBAction func onGuestImageTapped(_ sender: UITapGestureRecognizer) {
    }
    
    @IBAction func onPeriodUpTapped(_ sender: UITapGestureRecognizer) {
        sendData(cmd: CommandCodes.CMD_PERIOD_ADD)
    }
    
    @IBAction func onPeriodDownTapped(_ sender: UITapGestureRecognizer) {
        sendData(cmd: CommandCodes.CMD_PERIOD_SUB)
    }
    
    @IBAction func addHomeScore(_ sender: UITapGestureRecognizer) {
        sendData(cmd: CommandCodes.CMD_HOME_SCORE_UP)
    }
    
    @IBAction func subHomeScore(_ sender: UITapGestureRecognizer) {
        sendData(cmd: CommandCodes.CMD_HOME_SCORE_DOWN)
    }
    
    @IBAction func addGuestScore(_ sender: UITapGestureRecognizer) {
        sendData(cmd: CommandCodes.CMD_GUEST_SCORE_UP)
    }
    
    @IBAction func subGuestScore(_ sender: UITapGestureRecognizer) {
        sendData(cmd: CommandCodes.CMD_GUEST_SCORE_DOWN)
        
    }
    
    @IBAction func onPeriodNameTapped(_ sender: UITapGestureRecognizer) {
        showPeriodNamePickerDialog()
    }
    
    @IBAction func onPosBonusButtonClicked(_ sender: UIButton) {
        //Button的tag值为相应的命令码
        sendData(cmd: UInt8(sender.tag))
    }
    
    @IBAction func onBuzzerButtonClicked(_ sender: UIButton) {
        if TcpConnection.sharedInstance.isConnected() {
            let msg = "{\"effect\":buzzMP3}"
            TcpConnection.sharedInstance.send(data: msg.data(using: .utf8)!, tag: 0)
        } else {
            print("tcp disconnectd\n")
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
        updateUI(data: data!)
    }
    
    //MARK UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if pickerView.tag == 0 {
            return 50
        } else if pickerView.tag == 1 {
            return 100
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            switch component {
            case 0:
                return hours[row]
            case 1:
                return minutes[row]
            case 2:
                return seconds[row]
            default:
                break
            }
        } else if pickerView.tag == 1 {
            return periodNames[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            switch component {
            case 0:
                hour = row
            case 1:
                minute = row
            case 2:
                second = row
            default:
                break
            }
        } else if pickerView.tag == 1 {
            periodName = periodNames[row]
        }
    }
    
    //MARK UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == 0 {
            return 3
        } else if pickerView.tag == 1{
            return 1
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            switch component {
            case 0:
                return hours.count
            case 1:
                return minutes.count
            case 2:
                return seconds.count
            default:
                break
            }
        } else if pickerView.tag == 1 {
            return periodNames.count
        }
        return 0
    }
    
}
