//
//  ScoreboardViewHorizontal.swift
//  GameTimer
//
//  Created by devel on 16/10/25.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import Foundation
import UIKit

class ScoreboardView:UIView, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{
    
    //#MARK Attributes
    var hours:[String]!
    var minutes:[String]!
    var seconds:[String]!
    
    let periodNames = ["PERIOD", "HALF", "QUARTER", "INNING", "SET", "ROUND"]
    
    var hour = 0
    var minute = 0
    var sec = 0
    
    var periodName = "PERIOD"
    
    var controller:ScoreboardViewController!
    
    var setHomeImage = false
    var setTimer = false
    
    var homeGuestSwitch = false
    
    var buzzerLongPressed = false
    
    //MARK Outlets
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var periodNameLabel: UILabel!
    
    @IBOutlet weak var homeImage: UIImageView!
    @IBOutlet weak var guestImage: UIImageView!
    @IBOutlet weak var homeNameLabel: UILabel!
    @IBOutlet weak var guestNameLabel: UILabel!
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var guestLabel: UILabel!
    
    @IBOutlet weak var homeScoreLabel: UILabel!
    @IBOutlet weak var homePoss: UIButton!
    @IBOutlet weak var homeBonus: UIButton!
    
    @IBOutlet weak var guestScoreLabel: UILabel!
    @IBOutlet weak var guestPoss: UIButton!
    @IBOutlet weak var guestBonus: UIButton!
    
    @IBOutlet weak var buzzerButton: UIButton!
    
    @IBOutlet weak var connectStatusButton: UIButton!
    
    
    
    
    //MARK Funcs
    //从Bundle中读出时间项
    func initTimerPickerComponents() {
        let dictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "timePickerList", ofType: "plist")!) as! [String:[String]]
        
        hours = dictionary["hour"]
        minutes = dictionary["minute"]
        seconds = dictionary["second"]
    }
    
    func initViewStatus(sourceView: ScoreboardView?) {
        if TcpConnection.sharedInstance.isConnected() {
            connectStatusButton.isSelected = true
            connectStatusButton.setTitle("Connected", for: .normal)
        } else {
            connectStatusButton.isSelected = false
            connectStatusButton.setTitle("Disconnected", for: .normal)
        }
        
        initPossBonusView()
        
        if let view = sourceView {
            
            self.homeGuestSwitch = view.homeGuestSwitch
            
            self.timeLabel.text = view.timeLabel.text
            self.periodNameLabel.text = view.periodNameLabel.text
            self.periodName = view.periodName
            self.homeImage.image = view.homeImage.image
            self.guestImage.image = view.guestImage.image
            self.homeNameLabel.text = view.homeNameLabel.text
            self.guestNameLabel.text = view.guestNameLabel.text
            self.homeScoreLabel.text = view.homeScoreLabel.text
            self.guestScoreLabel.text = view.guestScoreLabel.text
            self.homePoss.isSelected = view.homePoss.isSelected
            self.homeBonus.isSelected = view.homeBonus.isSelected
            self.guestPoss.isSelected = view.guestPoss.isSelected
            self.guestBonus.isSelected = view.guestBonus.isSelected
        }
        
        //设置客队poss箭头在文字右边
        guestPoss.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(guestPoss.imageView?.frame.size.width)!, bottom: 0, right: (guestPoss.imageView?.frame.size.width)!)
        guestPoss.imageEdgeInsets = UIEdgeInsets(top: 0, left: (guestPoss.titleLabel?.frame.size.width)!, bottom: 0, right:-(guestPoss.titleLabel?.frame.size.width)!)
        
    }
    
    func initPossBonusView() -> Void {
        homePoss.setImage(#imageLiteral(resourceName: "icon_left_poss_dark"), for: .normal)
        homePoss.setImage(#imageLiteral(resourceName: "icon_left_poss_light"), for: .selected)
        
        guestPoss.setImage(#imageLiteral(resourceName: "icon_right_poss_dark"), for: .normal)
        guestPoss.setImage(#imageLiteral(resourceName: "icon_right_poss_light"), for: .selected)
        
        homeBonus.setImage(#imageLiteral(resourceName: "icon_bonus_dark"), for: .normal)
        homeBonus.setImage(#imageLiteral(resourceName: "icon_bonus_light"), for: .selected)
        
        guestBonus.setImage(#imageLiteral(resourceName: "icon_bonus_dark"), for: .normal)
        guestBonus.setImage(#imageLiteral(resourceName: "icon_bonus_light"), for: .selected)
    }
    
    //收到设备端广播后，更新UI显示
    func updateUI(data: ScoreboardData) {
        
        timeLabel.text = data.time
        periodLabel.text = "\(data.period)"
        homeScoreLabel.text = !homeGuestSwitch ? "\(data.hostScore)" : "\(data.guestScore)"
        guestScoreLabel.text = !homeGuestSwitch ? "\(data.guestScore)" : "\(data.hostScore)"
        switch data.bonus {
        case .guest:
            homeBonus.isSelected = homeGuestSwitch ? true : false
            guestBonus.isSelected = homeGuestSwitch ? false : true
        case .home:
            homeBonus.isSelected = homeGuestSwitch ? false : true
            guestBonus.isSelected = homeGuestSwitch ? true : false
        default:
            homeBonus.isSelected = false
            guestBonus.isSelected = false
            break;
        }
        
        switch data.poss {
        case .guest:
            homePoss.isSelected = homeGuestSwitch ? true : false
            guestPoss.isSelected = homeGuestSwitch ? false : true
        case .home:
            homePoss.isSelected = homeGuestSwitch ? false : true
            guestPoss.isSelected = homeGuestSwitch ? true : false
        default:
            homePoss.isSelected = false
            guestPoss.isSelected = false
            break
        }
    }
    
    //根据手机型号设置字体
    func initLabelFontSize() {
        if UIScreen.main.bounds.height == 480 {//iphone 4
            timeLabel.font = timeLabel.font.withSize(55)
            periodLabel.font = periodLabel.font.withSize(50)
            homeScoreLabel.font = homeScoreLabel.font.withSize(55)
            guestScoreLabel.font = guestScoreLabel.font.withSize(55)
            
            homeLabel.font = homeLabel.font.withSize(20)
            guestLabel.font = guestLabel.font.withSize(20)
            homeImage.frame.size = CGSize(width: 45, height: 45)
            homeImage.frame.size = CGSize(width: 45, height: 45)
            
        } else if UIScreen.main.bounds.height == 568 {//iphone 5
            timeLabel.font = timeLabel.font.withSize(65)
            periodLabel.font = periodLabel.font.withSize(60)
            homeScoreLabel.font = homeScoreLabel.font.withSize(65)
            guestScoreLabel.font = guestScoreLabel.font.withSize(65)
            
            homeLabel.font = homeLabel.font.withSize(30)
            guestLabel.font = guestLabel.font.withSize(30)
            homeImage.frame.size = CGSize(width: 50, height: 50)
            homeImage.frame.size = CGSize(width: 50, height: 50)
            
        } else if UIScreen.main.bounds.width == 375 {//iphone 6
            timeLabel.font = timeLabel.font.withSize(80)
            periodLabel.font = periodLabel.font.withSize(70)
            homeScoreLabel.font = homeScoreLabel.font.withSize(80)
            guestScoreLabel.font = guestScoreLabel.font.withSize(80)
            
            homeLabel.font = homeLabel.font.withSize(35)
            guestLabel.font = guestLabel.font.withSize(35)
            homeImage.frame.size = CGSize(width: 65, height: 65)
            homeImage.frame.size = CGSize(width: 65, height: 65)
            
        } else if UIScreen.main.bounds.width == 414 {//iphone 6s
            timeLabel.font = timeLabel.font.withSize(110)
            periodLabel.font = periodLabel.font.withSize(80)
            homeScoreLabel.font = homeScoreLabel.font.withSize(110)
            guestScoreLabel.font = guestScoreLabel.font.withSize(110)
            
            homeNameLabel.font = homeNameLabel.font.withSize(25)
            guestNameLabel.font = guestNameLabel.font.withSize(25)
            
            //设置poss bonus字体
            homePoss.titleLabel?.font = homePoss.titleLabel?.font.withSize(23)
            guestPoss.titleLabel?.font = guestPoss.titleLabel?.font.withSize(23)
            
            homeBonus.titleLabel?.font = homeBonus.titleLabel?.font.withSize(23)
            guestBonus.titleLabel?.font = guestBonus.titleLabel?.font.withSize(23)
            
            homeLabel.font = homeLabel.font.withSize(40)
            guestLabel.font = guestLabel.font.withSize(40)
            homeImage.frame.size = CGSize(width: 80, height: 80)
            homeImage.frame.size = CGSize(width: 80, height: 80)
        }
    }

    func showTimerPickerActionSheet() {
        let alert = UIAlertController(title: "GameTimer", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Timer Count Down", style: .default, handler: {(_) in
            self.showTimerCountDownDialog()}))
        alert.addAction(UIAlertAction(title: "Timer Count Up", style: .default, handler: {_ in self.showTimerCountUpDialog()}))
        alert.addAction(UIAlertAction(title: "Set Timer", style: .default, handler: {(_) in
            self.setTimer = true
            self.showTimerPickerDialog()}))
        alert.addAction(UIAlertAction(title: "Set Clock", style: .default, handler: {(_) in
            self.setTimer = false
            self.showTimerPickerDialog()}))
        alert.addAction(UIAlertAction(title: "Reset", style: .default, handler: {(_) in
            self.showResetDialog()}))
        controller.present(alert, animated: true, completion: nil)
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
        
        if setTimer {
            view.label1.text = "Min"
            view.label2.text = "Sec"
            view.titleLabel.text = "Timer Count Down"
        } else {
            view.label1.text = "HR"
            view.label2.text = "Min"
            view.titleLabel.text = "Clock"
        }
        
        view.frame = alert.view.frame
        view.layer.cornerRadius = 6.0
        alert.view.addSubview(view)
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    func showPeriodNamePickerDialog() {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.restorationIdentifier = "period"
        
        let views = Bundle.main.loadNibNamed("PickerView", owner: nil, options: nil)
        let view = views?[0] as! PickerView
        view.picker.dataSource = self
        view.picker.delegate = self
        
        view.picker.tag = 1
        
        view.confirm.addTarget(self, action: #selector(onCancelButtonClicked(sender:)), for: .touchUpInside)
        
        view.frame = alert.view.frame
        view.layer.cornerRadius = 6.0
        alert.view.addSubview(view)
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    func showTimerCountUpDialog() {
        let alert = UIAlertController(title: "Timer Count up", message: "Do you want to set Timer count up?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in self.controller.sendData(cmd: UInt8(CommandCodes.CMD_TIMER_COUNT_UP))}))
        controller.present(alert, animated: true, completion: nil)
    }
    
    func showTimerCountDownDialog() {
        let alert = UIAlertController(title: "Timer Count Down", message: "Do you want to set Timer count down?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in self.controller.sendData(cmd: UInt8(CommandCodes.CMD_TIMER_COUNT_DOWN))}))
        controller.present(alert, animated: true, completion: nil)
    }
    
    func showNameDialog(tag:Int) {
        let alert = UIAlertController(title: "Name", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(field: UITextField) in
            field.tag = tag
            field.delegate = self
            field.clearButtonMode = .always
            if tag == 0 {
                field.text = self.homeNameLabel.text
            } else {
                field.text = self.guestNameLabel.text
            }
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
    
    func showResetDialog() -> Void {
        let alert = UIAlertController(title: "Reset", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Reset All", style: .default, handler: { _ in
            let at = UIAlertController(title: "Reset All", message: "Do you want to Reset the Timer,Home Score,Away score and the Period?", preferredStyle: .alert)
            at.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
            at.addAction(UIAlertAction(title: "YES", style: .default, handler: { _ in
                TcpConnection.sharedInstance.send(cmd: "reset", value: "0", extra: nil)
            }))
            self.controller.present(at, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Reset Timer", style: .default, handler: { _ in
            let at = UIAlertController(title: "Reset Timer", message: "Do you want to Reset the Timer?", preferredStyle: .alert)
            at.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
            at.addAction(UIAlertAction(title: "YES", style: .default, handler: { _ in
                TcpConnection.sharedInstance.send(cmd: "reset", value: "1", extra: nil)
            }))
            self.controller.present(at, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Reset Home Score", style: .default, handler: { _ in
            let at = UIAlertController(title: "Reset Home Score", message: "Do you want to Reset Home Score?", preferredStyle: .alert)
            at.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
            at.addAction(UIAlertAction(title: "YES", style: .default, handler: { _ in
                TcpConnection.sharedInstance.send(cmd: "reset", value: "2", extra: nil)
            }))
            self.controller.present(at, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Reset Away Score", style: .default, handler: {_ in
            let at = UIAlertController(title: "Reset Away Score", message: "Do you want to Reset Away Score?", preferredStyle: .alert)
            at.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
            at.addAction(UIAlertAction(title: "YES", style: .default, handler: { _ in
                TcpConnection.sharedInstance.send(cmd: "reset", value: "3", extra: nil)
            }))
            self.controller.present(at, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Reset Period", style: .default, handler: { _ in
            let at = UIAlertController(title: "Reset Period", message: "Do you want to Reset the Period?", preferredStyle: .alert)
            at.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
            at.addAction(UIAlertAction(title: "YES", style: .default, handler: { _ in
                TcpConnection.sharedInstance.send(cmd: "reset", value: "4", extra: nil)
            }))
            self.controller.present(at, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
    
    //调整图片大小
    func scaleImage(image: UIImage) -> UIImage {
        var size:CGSize = CGSize(width: 60, height: 60)
        if UIScreen.main.bounds.height == 480 {//iphone 4
            size.width = 50
            size.height = 50
        } else if UIScreen.main.bounds.height == 568 {//iphone 5
            size.width = 60
            size.height = 60
        } else if UIScreen.main.bounds.width == 375 {//iphone 6
            size.width = 70
            size.height = 70
        } else if UIScreen.main.bounds.width == 414 {//iphone 6s
            size.width = 90
            size.height = 90
        }

        UIGraphicsBeginImageContextWithOptions(size, true, 1)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    //MARK objc
    @objc func onCancelButtonClicked(sender:UIAlertController) {
        controller.dismiss(animated: true, completion: nil)
        if sender.restorationIdentifier == "period" {
            periodNameLabel.text = periodName
        }
    }
    
    @objc func onOKButtonClicked(sender:UIAlertController) {
        let secs = hour*60*60 + minute*60 + sec
        if TcpConnection.sharedInstance.isConnected() {
            var msg:String? = nil
            if setTimer {
                msg = "{\"cmd\":\"circle\",\"value\":\"\(secs)\"}"
            } else {
                msg = "{\"cmd\":\"time\",\"value\":\"\(secs)\"}"
            }
            TcpConnection.sharedInstance.send(data: (msg?.data(using: .utf8)!)!, tag: 0)
        } else {
            print("Tcp disconnected\n")
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    //MARK Actions
    @IBAction func onTimeLabelTapped(_ sender: UITapGestureRecognizer) {
        if !ModeCheckUtils.canControlScoreboard() {
            return
        }
        controller.sendData(cmd: CommandCodes.CMD_TIMER_PLAY)
    }
    
    @IBAction func onTimeLabelLongpressed(_ sender: UILongPressGestureRecognizer) {
        if !ModeCheckUtils.canControlScoreboard() {
            return
        }
        if sender.state == .began {
            showTimerPickerActionSheet()
        }
    }

    @IBAction func onHomeImageTapped(_ sender: UITapGestureRecognizer) {
        print("onHomeImageTapped\n")
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        setHomeImage = true
        controller.willShowImagePicker = true
        controller.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func onGuestImageTapped(_ sender: UITapGestureRecognizer) {
        print("onGuestImageTapped\n")
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        setHomeImage = false
        controller.willShowImagePicker = true
        controller.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func onHomeNameTapped(_ sender: UITapGestureRecognizer) {
        showNameDialog(tag: 0)
    }
    
    @IBAction func onGuestNameTapped(_ sender: UITapGestureRecognizer) {
        showNameDialog(tag: 1)
    }
    
    @IBAction func onPeriodUpTapped(_ sender: UITapGestureRecognizer) {
        print("onPeriodUpTapped\n")
        if !ModeCheckUtils.canControlScoreboard() {
            return
        }
        controller.sendData(cmd: CommandCodes.CMD_PERIOD_ADD)
    }
    
    @IBAction func onPeriodDownTapped(_ sender: UITapGestureRecognizer) {
        print("onPeriodDownTapped\n")
        if !ModeCheckUtils.canControlScoreboard() {
            return
        }
        controller.sendData(cmd: CommandCodes.CMD_PERIOD_SUB)
    }
    
    @IBAction func addHomeScore(_ sender: UITapGestureRecognizer) {
        print("addHomeScore\n")
        if !ModeCheckUtils.canControlScoreboard() {
            return
        }
        if !homeGuestSwitch {
            controller.sendData(cmd: CommandCodes.CMD_HOME_SCORE_UP)
        } else {
            controller.sendData(cmd: CommandCodes.CMD_GUEST_SCORE_UP)
        }
    }
    
    @IBAction func subHomeScore(_ sender: UITapGestureRecognizer) {
        print("subHomeScore\n")
        if !ModeCheckUtils.canControlScoreboard() {
            return
        }
        if !homeGuestSwitch {
            controller.sendData(cmd: CommandCodes.CMD_HOME_SCORE_DOWN)
        } else {
            controller.sendData(cmd: CommandCodes.CMD_GUEST_SCORE_DOWN)
        }
    }
    
    @IBAction func addGuestScore(_ sender: UITapGestureRecognizer) {
        print("addGuestScore\n")
        if !ModeCheckUtils.canControlScoreboard() {
            return
        }
        if !homeGuestSwitch {
            controller.sendData(cmd: CommandCodes.CMD_GUEST_SCORE_UP)
        } else {
            controller.sendData(cmd: CommandCodes.CMD_HOME_SCORE_UP)
        }
    }
    
    @IBAction func subGuestScore(_ sender: UITapGestureRecognizer) {
        print("subGuestScore\n")
        if !ModeCheckUtils.canControlScoreboard() {
            return
        }
        if !homeGuestSwitch {
            controller.sendData(cmd: CommandCodes.CMD_GUEST_SCORE_DOWN)
        } else {
            controller.sendData(cmd: CommandCodes.CMD_HOME_SCORE_DOWN)
        }
        
    }
    
    @IBAction func onPeriodNameTapped(_ sender: UITapGestureRecognizer) {
        print("onPeriodNameTapped\n")
        showPeriodNamePickerDialog()
    }
    
    @IBAction func onPosBonusButtonClicked(_ sender: UIButton) {
        print("onPosBonusButtonClicked\n")
        //Button的tag值为相应的命令码
        if !ModeCheckUtils.canControlScoreboard() {
            return
        }
        var cmd = UInt8(sender.tag)
        if homeGuestSwitch {
            switch  UInt8(sender.tag) {
            case CommandCodes.CMD_HOME_POSS:
                cmd = CommandCodes.CMD_GUEST_POSS
                break;
            case CommandCodes.CMD_GUEST_POSS:
                cmd = CommandCodes.CMD_HOME_POSS
                break;
            case CommandCodes.CMD_HOME_BUNUS:
                cmd = CommandCodes.CMD_GUEST_BUNUS
                break;
            case CommandCodes.CMD_GUEST_BUNUS:
                cmd = CommandCodes.CMD_HOME_BUNUS
                break;
            default:
                break;
            }
        }
        controller.sendData(cmd: cmd)
    }
    
    @IBAction func onBuzzerButtonClicked(_ sender: UIButton) {
        print("onBuzzerButtonClicked\n")
        if !ModeCheckUtils.canControlScoreboard() || buzzerLongPressed {
            return
        }
        if TcpConnection.sharedInstance.isConnected() {
            TcpConnection.sharedInstance.send(cmd: "button", value: "\(CommandCodes.CMD_BUZZER)", extra: nil)
        } else {
            print("tcp disconnectd\n")
        }
    }
    
    @IBAction func onBuzzerLongPressed(_ sender: UILongPressGestureRecognizer) {
        print("onBuzzerLongPressed\n")
        if !ModeCheckUtils.canControlScoreboard() {
            return
        }
        if sender.state == .began {
            buzzerLongPressed = true
            TcpConnection.sharedInstance.send(cmd: "button", value: "\(CommandCodes.CMD_BUZZER_LONGPRESSED)", extra: nil)
        } else if sender.state == .ended {
            buzzerLongPressed = false
            TcpConnection.sharedInstance.send(cmd: "button", value: "\(CommandCodes.CMD_BUZZER_LONGPRESS_RELEASE)", extra: nil)
        }
    }
    
    
    @IBAction func connectToDevice(_ sender: UIButton) {
        print("connectToDevice\n")
        if !TcpConnection.sharedInstance.isConnected() {
            let alert = UIAlertController(title: "Connect to GameTimer", message: "Connect to GameTimer?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Connect", style: .default, handler: {_ in
                TcpConnection.sharedInstance.connect(host: "192.168.222.254", port: 0x8888)
            }))
            controller.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func homeGuestSwitch(_ sender: UIButton) {
        print("homeGuestSwitch\n")
        homeGuestSwitch = !homeGuestSwitch
        let tempImage = homeImage.image
        homeImage.image = guestImage.image
        guestImage.image = tempImage
        
        var tempStr = homeLabel.text
        homeLabel.text = guestLabel.text
        guestLabel.text = tempStr
        
        tempStr = homeNameLabel.text
        homeNameLabel.text = guestNameLabel.text
        guestNameLabel.text = tempStr
        
        tempStr = homeScoreLabel.text
        homeScoreLabel.text = guestScoreLabel.text
        guestScoreLabel.text = tempStr
        
        var tempBool = homePoss.isSelected
        homePoss.isSelected = guestPoss.isSelected
        guestPoss.isSelected = tempBool
        
        tempBool = homeBonus.isSelected
        homeBonus.isSelected = guestBonus.isSelected
        guestBonus.isSelected = tempBool
        
    }
    
    //MARK UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if pickerView.tag == 0 {
            return 50
        } else if pickerView.tag == 1 {
            return 150
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            switch component {
            case 0:
                if setTimer {
                    return minutes[row]
                } else {
                    return hours[row]
                }
            case 1:
                if setTimer {
                    return seconds[row]
                } else {
                    return minutes[row]
                }
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
                if setTimer {
                    minute = row
                } else {
                    hour = row
                }
            case 1:
                if setTimer {
                    sec = row
                } else {
                    minute = row
                }
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
            return 2
        } else if pickerView.tag == 1{
            return 1
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            switch component {
            case 0:
                if setTimer {
                    return minutes.count
                } else {
                    return hours.count
                }
            case 1:
                if setTimer {
                    return minutes.count
                } else {
                    return seconds.count
                }
            default:
                break
            }
        } else if pickerView.tag == 1 {
            return periodNames.count
        }
        return 0
    }
    
    //MARK UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel\n")
        controller.dismiss(animated: true, completion: nil)
        controller.willShowImagePicker = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("imagePickerController \(homeImage.frame)\n")
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        let newImage = scaleImage(image: image)
        if setHomeImage == true {
            homeImage.image = newImage
        } else {
            guestImage.image = newImage
        }
        controller.dismiss(animated: true, completion: nil)
        controller.willShowImagePicker = false
    }
    
    //MARK UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            homeNameLabel.text = textField.text
        } else if textField.tag == 1 {
            guestNameLabel.text = textField.text
        }
    }
    
}
