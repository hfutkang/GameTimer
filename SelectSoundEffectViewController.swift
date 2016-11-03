//
//  SelectSoundEffectViewController.swift
//  GameTimer
//
//  Created by devel on 16/10/8.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import UIKit
import MediaPlayer

class SelectSoundEffectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MPMediaPickerControllerDelegate, UITextFieldDelegate {
    
    //MARK attributes
    var appUrls = [URL]()
    var phoneUrls = [URL]()
    var micUrls = [URL]()
    
    let docUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    var eventName = ""
    
    var selectedRow:IndexPath!
    var selectedUrl:URL!
    
    var soundPlayer:AVAudioPlayer!
    var soundExportSession:AVAssetExportSession!
    
    var soundName:String?
    
    //MARK Outlets
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        
        appUrls = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: "SFX")!
        _initAvSession()
        _initPhoneUrls()
        _initMicUrls()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear\n")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear\n")
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
    
    func _initPhoneUrls() -> Void {
        
        let phoneSoundPath = docUrl.path.appending("/phoneSound")
        print("\(phoneSoundPath)\n")
        var isDir = ObjCBool(false)
        let exist = FileManager.default.fileExists(atPath: phoneSoundPath, isDirectory: UnsafeMutablePointer<ObjCBool>(&isDir))
        if  !exist || !isDir.boolValue {
            do {
                try FileManager.default.createDirectory(at: URL(fileURLWithPath: phoneSoundPath), withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Fail to create dir\n")
            }
            return
        }
        
        let dirEnumerator = FileManager.default.enumerator(atPath: phoneSoundPath)
        let soundFiles = dirEnumerator?.allObjects as! [String]
        
        for sound in soundFiles {
            let url = URL(fileURLWithPath: phoneSoundPath + "/" + sound)
            phoneUrls.append(url)
        }
    }
    
    func _initMicUrls() -> Void {
        
        let micSoundPath = docUrl.path.appending("/micSound")
        print("\(micSoundPath)\n")
        var isDir = ObjCBool(false)
        let exist = FileManager.default.fileExists(atPath: micSoundPath, isDirectory: UnsafeMutablePointer<ObjCBool>(&isDir))
        if  !exist || !isDir.boolValue {
            do {
                try FileManager.default.createDirectory(at: URL(fileURLWithPath: micSoundPath), withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Fail to create dir\n")
            }
            return
        }
        
        let dirEnumerator = FileManager.default.enumerator(atPath: micSoundPath)
        let soundFiles = dirEnumerator?.allObjects as! [String]
        
        for sound in soundFiles {
            let url = URL(fileURLWithPath: micSoundPath + "/" + sound)
            micUrls.append(url)
        }
    }

    
    func copySoundToApp(item: MPMediaItem, withName: String) -> Void {
        let dirUrl = docUrl.appendingPathComponent("phoneSound")
        
        let outUrl = dirUrl.appendingPathComponent(item.title! + ".mov")
        let localUrl = dirUrl.appendingPathComponent(withName + ".mp3")

        let urlAsset = AVURLAsset(url: item.assetURL!)
        
        soundExportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetPassthrough)
        soundExportSession.outputFileType = AVFileTypeQuickTimeMovie
        soundExportSession.outputURL = outUrl
        
        soundExportSession.exportAsynchronously(completionHandler: {() -> Void in
            switch self.soundExportSession.status {
            case .completed:
                print("export audio completed\n")
                do {
                    try FileManager.default.moveItem(at: outUrl, to: localUrl)
                } catch {
                    print("copy file failed \(error)\n")
                    return
                }
                let indexPath = IndexPath(item: self.phoneUrls.count, section: 1)
                self.phoneUrls.append(localUrl)
                self.tableView.insertRows(at: [indexPath], with: .bottom)
            case .failed:
                print("export failed \(self.soundExportSession.error)\n")
            case .unknown:
                print("export failed unkown\n")
            case .cancelled:
                print("export canceled\n")
            case .exporting:
                print("exporting\n")
                
            default:
                print("\(self.soundExportSession.status)\n")
                break;
            }
        })
        
    }
    
    func fileExist(name: String, dir: String) -> Bool {
        let url = docUrl.appendingPathComponent(dir + "/" + name)
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    //MARK Actions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    @IBAction func pickEffectFromPhone(_ sender: UIButton) {
        let picker = MPMediaPickerController(mediaTypes: .anyAudio)
        picker.delegate = self
        picker.allowsPickingMultipleItems = false
        self.present(picker, animated: true, completion: nil)
    }
    
    //MARK UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return appUrls.count
        case 1:
            return phoneUrls.count
        case 2:
            return micUrls.count
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    //MARK UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedRow != nil {
            let oldSelectedCell = tableView.cellForRow(at: selectedRow)
            oldSelectedCell?.accessoryType = .none
        }
        
        let selectedCell = tableView.cellForRow(at: indexPath)
        selectedCell?.accessoryType = .checkmark
        selectedRow = indexPath
        
        switch indexPath.section {
        case 0:
            selectedUrl = appUrls[indexPath.row]
        case 1:
            selectedUrl = phoneUrls[indexPath.row]
        case 2:
            selectedUrl = micUrls[indexPath.row]
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt-------------\n")
        let cell = tableView.dequeueReusableCell(withIdentifier: "soundNameCell",
                                                 for: indexPath) as! SelectEffectTableViewCell
        switch indexPath.section {
        case 0:
            cell.name.text = appUrls[indexPath.row].lastPathComponent
            let url1 = appUrls[indexPath.row].absoluteString
            let url2 = UserDefaults.standard.url(forKey: eventName)?.absoluteString
            if selectedRow == nil && url1 == url2! {
                selectedRow = indexPath
            }
        case 1:
            cell.name.text = phoneUrls[indexPath.row].lastPathComponent
            let url1 = phoneUrls[indexPath.row].absoluteString
            let url2 = UserDefaults.standard.url(forKey: eventName)?.absoluteString
            if selectedRow == nil && url1 == url2! {
                selectedRow = indexPath
            }
        case 2:
            cell.name.text = micUrls[indexPath.row].lastPathComponent
            let url1 = micUrls[indexPath.row].absoluteString
            let url2 = UserDefaults.standard.url(forKey: eventName)?.absoluteString
            if selectedRow == nil && url1 == url2! {
                selectedRow = indexPath
            }
        default: break
        }
        
        if selectedRow == nil || selectedRow != indexPath{
            cell.accessoryType = .none
        } else if selectedRow == indexPath {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "From app"
        case 1:
            return "From phome"
        case 2:
            return "From mic"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0:
            return false
        default:
            return true
        }
    }
    
    /*func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch indexPath.section {
            case 1:
                do {
                    try FileManager.default.removeItem(at: phoneUrls[indexPath.row])
                } catch {
                    
                }
                phoneUrls.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            case 2:
                do {
                    try FileManager.default.removeItem(at: micUrls[indexPath.row])
                } catch {
                    
                }
                micUrls.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            default:
                break
            }
        }
    }*/
    
    //MARK MPMediaPickerControllerDelegate
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        dismiss(animated: true, completion: nil)
        let items = mediaItemCollection.items
        let item = items[0]
        
        //检查音频长度，如果超过指定时长，弹出对话框
        if item.playbackDuration > 10 {
            let alterDialog = UIAlertController(title: "The audio duration is too long!", message: "", preferredStyle: .alert)
            alterDialog.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            self.present(alterDialog, animated: true, completion: nil)
            return
        }
        
        //由用户为导入音频命名
        let nameDialog = UIAlertController(title: "Sound effect name", message: "", preferredStyle: .alert)
        nameDialog.addTextField(configurationHandler: {(textFile: UITextField) -> Void in
            textFile.delegate = self
        })
        nameDialog.addAction(UIAlertAction(title: "Save", style: .default, handler: { (sender: UIAlertAction) -> Void in
            //判断名字有效性：是否为空，是否存在同名文件
            if let name = self.soundName {
                if name.isEmpty {//名字为空
                    let dialog = UIAlertController(title: "Empty fileName", message: "The filename is empty. Please enter a filename.", preferredStyle: .alert)
                    dialog.addAction(UIAlertAction(title: "Close", style: .default, handler: {_ in
                        self.present(nameDialog, animated: true, completion: nil)
                    }))//提示框关闭后，再次弹出命名对话框
                    self.present(dialog, animated: true, completion: nil)
                }
                if self.fileExist(name: name + ".mp3", dir: "phoneSound") {
                    let dialog = UIAlertController(title: "Name exist", message: "Sound effect name \(name) exist", preferredStyle: .alert)
                    dialog.addAction(UIAlertAction(title: "Close", style: .default, handler: {_ in
                        self.present(nameDialog, animated: true, completion: nil)
                    }))//提示框关闭后，再次弹出命名对话框
                    self.present(dialog, animated: true, completion: nil)
                } else {
                    self.copySoundToApp(item: item, withName: name)//不存在同名文件，开始导入
                }
            } else {//soundName等于nil，名字为空。
                let dialog = UIAlertController(title: "Empty fileName", message: "The filename is empty. Please enter a filename.", preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "Close", style: .default, handler: {_ in
                    self.present(nameDialog, animated: true, completion: nil)
                }))//提示框关闭后，再次弹出命名对话框
                self.present(dialog, animated: true, completion: nil)
            }
        }))
        nameDialog.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(nameDialog, animated: true, completion: nil)
    }
    
    //MARK UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        soundName = textField.text
    }
}
