//
//  ConnectControllViewContrller.swift
//  GameTimer
//
//  Created by devel on 16/11/4.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import Foundation
class ConnectControllViewContrller: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    //MARK Outlet
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK Attribute
    var idList:[Dictionary<String,Any>]?
    var ssid:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ConnectControllViewContrller viewDidLoad\n")
        // Do any additional setup after loading the view, typically from a nib.
        tableView.register(UINib(nibName: "ConnectedDeviceHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "connectedDeviceHeaderView")
        tableView.register(UINib(nibName: "ConnectedDevicePermissionCell", bundle: nil), forCellReuseIdentifier: "connectedDevicePermissionCell")
        
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 20/255.0, green: 23/255.0, blue: 35/255.0, alpha: 1)
        
        self.tabBarController?.tabBar.isTranslucent = false
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 20/255.0, green: 23/255.0, blue: 35/255.0, alpha: 1)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if ModeCheckUtils.isPrimary() {
            NotificationCenter.default.addObserver(self, selector: #selector(getIdlistFromGM(sender:)), name: NSNotification.Name("sctek.cn.MGameTimer.idlist"), object: nil)
            if TcpConnection.sharedInstance.isConnected() {
                let msg = "{\"cmd\":\"idlist\"}"
                TcpConnection.sharedInstance.send(data: msg.data(using: .utf8)!, tag: 0)
            } else {
                print("Tcp disconnected\n")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear\n")
        /*if ModeCheckUtils.isPrimary() {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("sctek.cn.MGameTimer.idlist"), object: nil)
        }
        idList = nil*/
    }
    
    //MARK Objec
    @objc func getIdlistFromGM(sender:Notification) {
        idList = sender.userInfo?["idlist"] as? [Dictionary<String, Any>]
        ssid = sender.userInfo?["ssid"] as? String
        
        print("\(idList) \(ssid)\n")
        
        tableView.reloadData()
    }
    
    @objc func onDeviceSwitchTapped(sender: UISwitch) {
        let section = sender.tag - 1
        let name = idList?[section]["name"] as! String
        
        TcpConnection.sharedInstance.send(cmd: "kick", value: name, extra: nil)
        
        idList?.remove(at: section)
        tableView.reloadData()
        
    }
    
    @objc func onPermissionSwitchTapped(sender: UISwitch) {
        let section = (sender.tag)/4 - 1
        let row = (sender.tag)%4
        
        let name = idList?[section]["name"] as! String
        let tempV = idList?[section]["mod"] as! Int
        var value = UInt8(tempV)
        value = value ^ UInt8(pow(Float(2), Float(row)))
        
        print("\(pow(Float(2), Float(row))) \(UInt8(pow(Float(2), Float(row))))\n")
        print("onPermissionSwitchTapped \(name) \(value)\n")
        
        idList?[section]["mod"] = Int(value)//将mod类型转换为Int，如果不转换，在cellForRowAt中提取的时候回出错。
        
        TcpConnection.sharedInstance.send(cmd: "chmod", value: "\(value)", extra: ["id":name])
    }
    
    //MARK UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        if !ModeCheckUtils.isPrimary() {
            return 0
        }
        
        if let ids = idList {
            return ids.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !ModeCheckUtils.isPrimary() {
            return 0
        }
        
        if section == 0 {
            return 1
        } else {
            return 4
        }
    }
    
    //MARK UITableViewDelegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt \(indexPath)\n")
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "wifiName", for: indexPath) as! WifiNameTableViewCell
            cell.wifiName.text = ssid
            return cell
            
        } else {
            let id = idList?[indexPath.section - 1]
            let mode = UInt8(id?["mod"] as! Int)
            let cell = tableView.dequeueReusableCell(withIdentifier: "connectedDevicePermissionCell", for: indexPath) as! PermissionTableViewCell
            switch indexPath.row{
            case 0:
                cell.permissionIcon.image = #imageLiteral(resourceName: "icon_scoreboard_dark")
                cell.permissionSwitch.isOn = mode & 0x01 > 0
            case 1:
                cell.permissionIcon.image = #imageLiteral(resourceName: "icon_mic_dark")
                cell.permissionSwitch.isOn = mode & 0x02 > 0
            case 2:
                cell.permissionIcon.image = #imageLiteral(resourceName: "icon_sfx_dark")
                cell.permissionSwitch.isOn = mode & 0x04 > 0
            case 3:
                cell.permissionIcon.image = #imageLiteral(resourceName: "icon_music_dark")
                cell.permissionSwitch.isOn = mode & 0x08 > 0
            default:
                break
            }
            
            cell.permissionSwitch.tag = indexPath.section*4 + indexPath.row
            //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onPermissionSwitchTapped(sender:)))
            cell.permissionSwitch.addTarget(self, action: #selector(onPermissionSwitchTapped(sender:)), for: .valueChanged)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "connectedDeviceHeaderView") as! ConnectedDeviceHeaderView
            header.nameLabel.text = idList?[section - 1]["name"] as? String
            header.switchButton.isOn = true
            
            header.switchButton.tag = section
            //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onDeviceSwitchTapped(sender:)))
            header.switchButton.addTarget(self, action: #selector(onDeviceSwitchTapped(sender:)), for: .valueChanged)
            
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let alert = UIAlertController(title: "GameTimer`s SSID", message: "Chang take effect after reboot", preferredStyle: .alert)
            alert.addTextField(configurationHandler: {textField in
                textField.delegate = self
                textField.text = self.ssid
                textField.clearButtonMode = .always
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                let text = alert.textFields?[0].text
                if (text?.isEmpty)! {
                    let warnAlert = UIAlertController(title: "Invalid SSID", message: "SSID cannot be empty!", preferredStyle: .alert)
                    warnAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(warnAlert, animated: true, completion: nil)
                } else {
                    if self.ssid != text {
                        self.ssid = text
                        TcpConnection.sharedInstance.send(cmd: "ssid", value: self.ssid!, extra: nil)
                        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! WifiNameTableViewCell
                        cell.wifiName.text = text
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 {
            return 69.0
        }
        return 35
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "GameTimer`s SSID"
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 69.0
    }/**/
    
    //MARK UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}
