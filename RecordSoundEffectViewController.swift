//
//  RecordSoundEffectViewController.swift
//  GameTimer
//
//  Created by devel on 16/10/10.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import UIKit
import AVFoundation
class RecordSoundEffectViewController: UIViewController, AVAudioRecorderDelegate, UITextFieldDelegate {
    
    //MARK Attributes
    var seconds = 0 {
        didSet(value) {
            if value < 10 {
                secLable.text = "0\(value)"
            } else {
                secLable.text = "\(value)"
            }
            
        }
    }
    var microsesonds = 0 {
        didSet(value) {
            let tv = value%100
            if tv < 10 {
                micSecLabel.text = "0\(tv)"
            } else {
                micSecLabel.text = "\(tv)"
            }
        }
        
    }
    
    var recorder:AVAudioRecorder!
    var recording = false
    let tempFileUrl = URL(fileURLWithPath: NSTemporaryDirectory() + "/temp.m4a")
    let docUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    var timer:Timer!
    
    var recorderName:String?
    
    //MARK Outlets
    @IBOutlet weak var secLable: UILabel!
    @IBOutlet weak var micSecLabel: UILabel!
    @IBOutlet weak var record: UIButton!
    @IBOutlet weak var recDotImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("RecordSoundEffectViewController viewDidLoad\n")
        //设置导航栏背景颜色
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 20/255.0, green: 23/255.0, blue: 35/255.0, alpha: 1)
        
        record.setImage(#imageLiteral(resourceName: "icon_rec_play_normal"), for: .normal)
        record.setImage(#imageLiteral(resourceName: "icon_rec_play_clicked"), for: .highlighted)
    }
    
    func initRecord() -> Bool {
        
        let settings = Dictionary(dictionaryLiteral: (AVSampleRateKey, NSNumber(value: 44100.0)), (AVFormatIDKey, NSNumber(value: kAudioFormatAppleLossless)), (AVNumberOfChannelsKey, NSNumber(value: 1)), (AVEncoderAudioQualityKey, NSNumber(value: kAudioConverterQuality_Max)))
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
            try AVAudioSession.sharedInstance().setActive(true)
            try recorder = AVAudioRecorder(url: tempFileUrl, settings: settings)
        } catch {
            print("cannot init recorder \(error.localizedDescription)\n")
            return false
        }
        recorder.delegate = self
        return true
    }
    
    func fileExist(name: String, dir: String) -> Bool {
        let url = docUrl.appendingPathComponent(dir + "/" + name)
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    //返回音效选择页面，并更新音效列表
    func returnToPreViewController(url: URL) -> Void {
        let controllers = self.navigationController?.viewControllers
        let preController = controllers?[(controllers?.count)! - 2] as! SelectSoundEffectViewController
        let indexPath = IndexPath(item: preController.micUrls.count, section: 2)
        preController.micUrls.append(url)
        preController.tableView.insertRows(at: [indexPath], with: .bottom)
        self.navigationController?.popToViewController(preController, animated: true)
    }
    
    func showNameDialog() -> Void {
        let nameDialog = UIAlertController(title: "Sound effect name", message: "", preferredStyle: .alert)
        nameDialog.addTextField(configurationHandler: {(textFile: UITextField) -> Void in
            textFile.delegate = self
        })
        nameDialog.addAction(UIAlertAction(title: "Save", style: .default, handler: { (sender: UIAlertAction) -> Void in
            //判断名字有效性：是否为空，是否存在同名文件
            if let name = self.recorderName {
                if name.isEmpty {//名字为空
                    let dialog = UIAlertController(title: "Empty fileName", message: "The filename is empty. Please enter a filename.", preferredStyle: .alert)
                    dialog.addAction(UIAlertAction(title: "Close", style: .default, handler: {_ in
                        self.present(nameDialog, animated: true, completion: nil)
                    }))
                    self.present(dialog, animated: true, completion: nil)
                }
                if self.fileExist(name: name + ".m4a", dir: "micSound") {//检查是否存在同名文件
                    let dialog = UIAlertController(title: "Name exist", message: "Sound effect name \(name) exist", preferredStyle: .alert)
                    dialog.addAction(UIAlertAction(title: "Close", style: .default, handler: {_ in
                        self.present(nameDialog, animated: true, completion: nil)
                    }))
                    self.present(dialog, animated: true, completion: nil)
                } else {//复制到Documents目录
                    let distUrl = self.docUrl.appendingPathComponent("micSound/" + name + ".m4a")
                    do {
                        try FileManager.default.moveItem(at: self.tempFileUrl, to: distUrl)
                    } catch {
                        print("fail to copy \(error)\n")
                        return
                    }
                    self.returnToPreViewController(url: distUrl)
                }
            } else {//soundName等于nil，说明名字也为空。
                let dialog = UIAlertController(title: "Empty fileName", message: "The filename is empty. Please enter a filename.", preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "Close", style: .default, handler: {_ in
                    self.present(nameDialog, animated: true, completion: nil)
                }))
                self.present(dialog, animated: true, completion: nil)
            }
        }))
        nameDialog.addAction(UIAlertAction(title: "Drop", style: .cancel, handler: nil))
        self.present(nameDialog, animated: true, completion: nil)
    }
    
    //停止录音，条件为到达最长录音时间或手动停止
    func stopRecord(t: Timer) -> Void {
        
        record.setImage(#imageLiteral(resourceName: "icon_rec_play_normal"), for: .normal)
        record.setImage(#imageLiteral(resourceName: "icon_rec_play_clicked"), for: .highlighted)
        recDotImage.image = #imageLiteral(resourceName: "icon_rec_dot_dark")
        
        t.invalidate()
        timer = nil
        seconds = 0
        microsesonds = 0
        
        recorder.stop()
        recorder = nil
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            
        }
        showNameDialog()
    }
    
    //MARK Actions
    @IBAction func record(_ sender: UIButton) {
        if let t = timer {
            stopRecord(t: t)
            return
        }
        
        if initRecord() {
            recorder.record()
            timer = Timer(timeInterval: 0.01, target: self, selector: #selector(timeChanged(sender:)), userInfo: nil, repeats: true)
            RunLoop.main.add(timer, forMode: .defaultRunLoopMode)
            timer.fire()
            
            record.setImage(#imageLiteral(resourceName: "icon_rec_stop_normal"), for: .normal)
            record.setImage(#imageLiteral(resourceName: "icon_rec_stop_clicked"), for: .highlighted)
            recDotImage.image = #imageLiteral(resourceName: "icon_rec_dot_blue")
        }
    }
    
    //MARK Objecs
    @objc func timeChanged(sender: Timer) {
        microsesonds += 1
        seconds = microsesonds/100
        if seconds >= 30 {
            stopRecord(t: sender)
        }
    }
    
    //MARK AVAudioRecorderDelegate
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("audioRecorderEncodeErrorDidOccur\n")
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("audioRecorderDidFinishRecording\n")
    }
    
    //MARK UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        recorderName = textField.text
    }
}
