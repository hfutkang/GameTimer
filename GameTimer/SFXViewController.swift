//
//  SecondViewController.swift
//  GameTimer
//
//  Created by devel on 16/9/13.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class SFXViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate {
    
    var sfxs:[String]!
    
    static var homeSwitchs:[String:Bool]! = [:]
    static var guestSwitchs:[String:Bool]! = [:]
    
    var isHomeSelected = true
    
    var soundPlayer:AVAudioPlayer!
    
    var playingRow:Int = -1

    //#MARK outlets
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var buzzerOnlySw: UISwitch!
    
    @IBOutlet weak var accessView: UIView!
    
    @IBOutlet weak var silentSwitchButton: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SFXViewController viewDidLoad\n")
        tableView.delegate = self
        tableView.dataSource = self
        
        sfxs = loadSFXs()
        
        initSwitchs(sfxs: sfxs)
        
        //设置导航栏背景颜色
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 20/255.0, green: 23/255.0, blue: 35/255.0, alpha: 1)
        
        self.tabBarController?.tabBar.isTranslucent = true
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 20/255.0, green: 23/255.0, blue: 35/255.0, alpha: 1)
        
        //读取设备当前的声音状态
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveSoundState(sender:)), name: NSNotification.Name("sctek.cn.MGameTimer.soundStatus"), object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        accessView.isHidden = ModeCheckUtils.canPlaySFX()
        
        _initVolumeView()
        
        if ModeCheckUtils.canPlaySFX() {
            let msg = "{\"cmd\":\"soundStatus\"}"
            TcpConnection.sharedInstance.send(data: msg.data(using: .utf8)!, tag: 0)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! SelectSoundEffectViewController
        if let cell = sender as? SoundEffectTableViewCell {
            controller.eventName = sfxs[(tableView.indexPath(for: cell)?.row)!]
            controller.selectedUrl = UserDefaults.standard.url(forKey: controller.eventName)
        }
    }
    
    func  _initVolumeView() -> Void {
        
        let vv = MPVolumeView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        vv.showsRouteButton = true
        vv.showsVolumeSlider = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: vv)
    }
    
    func _initAvSession() -> Void {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            try session.setActive(true)
        } catch {
            print("\(error)\n")
        }
    }
    
    func _deinitAvSession() -> Void {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
         } catch {
            print("\(error)\n")
         }
    }
    
    func _initVaries() -> Void {
        tableView.delegate = self
        tableView.dataSource = self
        
        sfxs = loadSFXs()
        
        initSwitchs(sfxs: sfxs)
        
        //homeButton.addTarget(self, action: #selector(onHomeButtonClicked), for: .touchUpInside)
        //guestButton.addTarget(self, action: #selector(onGuestButtonClicked), for: .touchUpInside)
    }
    
    func visibleFor(row : Int) -> Bool {
        let visibleRows = tableView.indexPathsForVisibleRows
        for path in visibleRows! {
            if row == path.row {
                print("\(row)\n")
                return true
            }
        }
        return false
    }
    
    func showTurnMuteOnDialog() {
        let alert = UIAlertController(title: "Silent Mode", message: "Please not that all sounds including Music,SFX, Microphone and Buzzer will be turned OFF", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { _ in
            TcpConnection.sharedInstance.send(cmd: "button", value: "\(CommandCodes.CMD_BUZZER_MUTE_ON)", extra: nil)
            self.silentSwitchButton.isOn = true
            self.buzzerOnlySw.isEnabled = false
            self.tableView.reloadData()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    //#MARK actions
    
    @IBAction func onSwitchValueChanged(_ sender: UISwitch) {
        if sender.tag == 0 {
            if TcpConnection.sharedInstance.isConnected() {
                var msg:String? = nil
                if sender.isOn {
                    msg = "{\"cmd\":\"button\",\"value\":\"\(CommandCodes.CMD_BUZZERONLY_ON)\"}"
                } else {
                    msg = "{\"cmd\":\"button\",\"value\":\"\(CommandCodes.CMD_BUZZERONLY_OFF)\"}"
                }
                TcpConnection.sharedInstance.send(data: (msg?.data(using: .utf8)!)!, tag: 0)
            } else {
                print("tcp disconnected\n")
            }
        }
        tableView.reloadData()
    }
    
    @IBAction func onSlientSwitchButtonClicked(_ sender: UITapGestureRecognizer) {
        if !TcpConnection.sharedInstance.isConnected() {
            print("Tcp disconnected\n")
            return
        }
        if silentSwitchButton.isOn {
            TcpConnection.sharedInstance.send(cmd: "button", value: "\(CommandCodes.CMD_BUZZER_MUTE_OFF)", extra: nil)
            silentSwitchButton.isOn = false
            buzzerOnlySw.isEnabled = true
        } else {
            showTurnMuteOnDialog()
        }
    }
    
    
    @IBAction func unWindToSoundEffectsView(sender: UIStoryboardSegue) {
        let source = sender.source as! SelectSoundEffectViewController
        UserDefaults.standard.set(source.selectedUrl, forKey: source.eventName)
        let selectedIndex = tableView.indexPathForSelectedRow
        if visibleFor(row: (selectedIndex?.row)!) {
            let cell = tableView.cellForRow(at: selectedIndex!) as! SoundEffectTableViewCell
            cell.soundLabel.text = source.selectedUrl.lastPathComponent
        }
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //MARK Objec
    @objc func onReceiveSoundState(sender: Notification) {
        buzzerOnlySw.isOn = sender.userInfo?["buzzer"] as! Bool
        silentSwitchButton.isOn = sender.userInfo?["mute"] as! Bool
        self.tableView.reloadData()
    }
    
    @objc func onSwitchChangde(sender : UISwitch) -> Void {
        SFXViewController.homeSwitchs[sfxs[sender.tag]] = sender.isOn
        let cell = self.tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0))as! SoundEffectTableViewCell
        cell.play.isEnabled = !silentSwitchButton.isOn && !buzzerOnlySw.isOn && sender.isOn
    }
    
    @objc func onPlayClicked(sender: UIButton) -> Void {
        print("onPlayClicked:\(sender.tag) \(sfxs[sender.tag])\n")
        let url = UserDefaults.standard.url(forKey: sfxs[sender.tag])
        print("url \(url)\n")
        if soundPlayer == nil {
            do {
                _initAvSession()
                try soundPlayer = AVAudioPlayer(contentsOf: url!)
                soundPlayer.delegate = self
                soundPlayer.play()
                sender.setTitle("stop", for: .normal)
                playingRow = sender.tag
                print("playing\n")
            } catch {
                print("init audio player fail \(error)\n")
                soundPlayer = nil
                _deinitAvSession()
            }
            return
        } else if soundPlayer.isPlaying {
            print("another playing\n")
            if sender.tag == playingRow {
                soundPlayer.stop()
                sender.setTitle("play", for: .normal)
                playingRow = -1
                soundPlayer = nil
                _deinitAvSession()
            } else {
                soundPlayer.stop()
                soundPlayer = nil
                if visibleFor(row: playingRow) {
                    let cell = tableView.cellForRow(at: IndexPath(row: playingRow, section: 0)) as! SoundEffectTableViewCell
                    cell.play.setTitle("play", for: .normal)
                }
                do {
                    print("another playing \(url)\n")
                    try soundPlayer = AVAudioPlayer(contentsOf: url!)
                    soundPlayer.delegate = self
                } catch {
                    print("init audio player fail \(soundPlayer) \(error)\n")
                    soundPlayer = nil
                    return
                }
                soundPlayer.play()
                sender.setTitle("stop", for: .normal)
                playingRow = sender.tag
            }
        }
    }
    
    @objc func onTableViewCellLongPressed(sender:UILongPressGestureRecognizer) -> Void {
        print("onTableViewCellLongPressed\n")
        if sender.state == .ended {
            let point = sender.location(in: self.tableView)
            let indexPath = self.tableView.indexPathForRow(at: point)
            print("\(indexPath)\n")
            
            let selectView = SelectSoundEffectViewController(nibName: "SelectSoundEffectView", bundle: nil)
            self.navigationController?.pushViewController(selectView, animated: true)
        }
    }
    
    func loadSFXs() -> [String] {
        let path = Bundle.main.path(forResource: "sfxList", ofType: "plist")
        let array = NSMutableArray(contentsOfFile: path!)
        return array?.copy() as! [String]
    }
    
    func initSwitchs( sfxs: [String] ) -> Void {
        
        if SFXViewController.homeSwitchs.count != 0 {
            return
        }
        
        for sfx in sfxs {
            SFXViewController.homeSwitchs[sfx] = true
            SFXViewController.guestSwitchs[sfx] = true
        }
    }
    
    //#MARK UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sfxs.count;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //#MARK UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt \(sfxs[indexPath.row])\n")
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellFOrRowAtIndexPath \(indexPath.row)")
        let cellIdentifier = "tableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                 for: indexPath) as! SoundEffectTableViewCell
        cell.nameLabel.text = sfxs[indexPath.row]
        let url = UserDefaults.standard.url(forKey: sfxs[indexPath.row])
        
        cell.soundLabel.text = url?.lastPathComponent
        
        cell.switchButton.isOn = SFXViewController.homeSwitchs[sfxs[indexPath.row]]!
        
        cell.switchButton.tag = indexPath.row
        cell.switchButton.addTarget(self, action: #selector(onSwitchChangde(sender:)), for: UIControlEvents.valueChanged)
        
        if indexPath.row == playingRow {
            cell.play.setTitle("stop", for: .normal)
        } else {
            cell.play.setTitle("play", for: .normal)
        }
        
        cell.play.tag = indexPath.row
        cell.play.addTarget(self, action: #selector(onPlayClicked(sender:)), for: .touchUpInside)
        
        cell.switchButton.isEnabled = !buzzerOnlySw.isOn && !silentSwitchButton.isOn
        cell.play.isEnabled = !silentSwitchButton.isOn && !buzzerOnlySw.isOn && cell.switchButton.isOn
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        
    }
    
    //#MARK AVAudioPlayerDelegate
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if visibleFor(row: playingRow) {
            let cell = tableView.cellForRow(at: IndexPath(row: playingRow, section: 0)) as! SoundEffectTableViewCell
            cell.play.setTitle("play", for: .normal)
        }
        playingRow = -1
        soundPlayer = nil
        _deinitAvSession()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("audioPlayerDidFinishPlaying\n")
        if visibleFor(row: playingRow) {
            let cell = tableView.cellForRow(at: IndexPath(row: playingRow, section: 0)) as! SoundEffectTableViewCell
            cell.play.setTitle("play", for: .normal)
        }
        soundPlayer = nil
        playingRow = -1
        _deinitAvSession()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 69.0
    }
    
}

