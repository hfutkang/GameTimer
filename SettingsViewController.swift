//
//  SettingsViewController.swift
//  GameTimer
//
//  Created by devel on 16/11/4.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import Foundation
import UIKit
class SettingsViewController:UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK Attributes
    var level:Int = -1
    
    let levelNames = ["Black Mode", "Clock intensity", "Medium", "INDOOR intnsity", "Bright", "Full intensity"]
    
    let blackModeWarnMsg = "Please note that all front panel LEDs will be turned OFF and you will only be able to use Scoreboard as Microphone or Music Player."
    
    //MARK Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var accessView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SettingsViewController viewDidLoad\n")
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 20/255.0, green: 23/255.0, blue: 35/255.0, alpha: 1)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        accessView.isHidden = ModeCheckUtils.isPrimary()
        if ModeCheckUtils.isPrimary() {
            NotificationCenter.default.addObserver(self, selector: #selector(getLedLevelFromGM(sender:)), name: NSNotification.Name("sctek.cn.MGameTimer.brightnessLevel"), object: nil)
            if TcpConnection.sharedInstance.isConnected() {
                let msg = "{\"cmd\":\"getLevel\"}"
                TcpConnection.sharedInstance.send(data: msg.data(using: .utf8)!, tag: 0)
            } else {
                print("Tcp disconnected\n")
            }
        }
        
    }
    
    //MARK funcs
    func showBrightnessLevelPickerDialog() {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        let views = Bundle.main.loadNibNamed("PickerView", owner: nil, options: nil)
        let view = views?[0] as! PickerView
        view.picker.dataSource = self
        view.picker.delegate = self
        
        view.titleLabel.text = "LED Brightness"
        
        view.confirm.addTarget(self, action: #selector(onOkButtonClicked(sender:)), for: .touchUpInside)
        
        view.frame = alert.view.frame
        view.layer.cornerRadius = 6.0
        alert.view.addSubview(view)
        
        self.present(alert, animated: true, completion: nil)
        view.picker.selectRow(level - 1, inComponent: 0, animated: true)
    }
    
    //MARK Objec
    @objc func getLedLevelFromGM(sender:Notification) {
        print("getLedLevelFromGM \(sender.userInfo)\n")
        level = (sender.userInfo?["level"] as? Int)!
        
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)], with: .none)
    }
    
    @objc func onOkButtonClicked(sender: UIAlertController) {
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! LedBrightnessTableViewCell
        if levelNames[self.level] != cell.brightnessLabel.text {
            cell.brightnessLabel.text = levelNames[self.level]
            TcpConnection.sharedInstance.send(cmd: "setLevel", value: "\(level)", extra: nil)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onBlackModeSwitchTapped(sender: UITapGestureRecognizer) {
        let cell1 = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! BlackModeTableViewCell
        let cell2 = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! LedBrightnessTableViewCell
        if level == 0 {
            cell1.blackModeSwitch.isOn = false
            TcpConnection.sharedInstance.send(cmd: "setLevel", value: "2", extra: nil)
            cell2.brightnessLabel.text = levelNames[2]
            level = 2 //关闭Black mode 后，默认设置亮度为medium
        } else {
            let alert = UIAlertController(title: "Black Mode", message: blackModeWarnMsg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "ACCEPT", style: .default, handler: {_ in
                self.level = 0
                TcpConnection.sharedInstance.send(cmd: "setLevel", value: "0", extra: nil)
                cell1.blackModeSwitch.isOn = true
                cell2.brightnessLabel.text = ""
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    //MARK UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt \(indexPath)\n")
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "blackMode", for: indexPath) as! BlackModeTableViewCell
            cell.view.isUserInteractionEnabled = level >= 0
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onBlackModeSwitchTapped(sender:)))
            cell.view.addGestureRecognizer(gestureRecognizer)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ledBrightness", for: indexPath) as! LedBrightnessTableViewCell
            cell.brightnessLabel.text = level > 0 ? levelNames[level] : ""
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt \(indexPath)\n")
        if indexPath.row == 1 {
            if level > 0 {
                showBrightnessLevelPickerDialog()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 69.0
    }/**/
    
    //MAKR UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
    //MAKR UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: levelNames[row + 1], attributes: [NSForegroundColorAttributeName:UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        level = row + 1
    }
    
}
