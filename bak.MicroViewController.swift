//
//  MicroViewController.swift
//  GameTimer
//
//  Created by devel on 16/9/21.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer

/*class MicroViewController: UIViewController, AVAudioRecorderDelegate
                            , AVAudioPlayerDelegate, AVAudioSessionDelegate {
    
    //#MARK Outlets
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet var longPressGestureRcongnizer: UILongPressGestureRecognizer!
    
    var recording = false
    var playing = false
    var recorder:AVAudioRecorder!
    var player:AVAudioPlayer!
    var filePath = URL(fileURLWithPath: NSTemporaryDirectory() + "/micAudio.caf")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        _initVolumeView()
        
        _registerNotification()
        
        avAudioSession()
        
    }
    
    func  _initVolumeView() -> Void {
        
        let vv = MPVolumeView(frame: CGRect(x: 30, y: 50, width: self.view.frame.width - 50, height: 30))
        vv.sizeToFit()
        vv.showsRouteButton = true
        vv.showsVolumeSlider = true
        self.view.addSubview(vv)
    }
    
    func _registerNotification() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChanged(notification:)), name: .AVAudioSessionRouteChange, object: nil)
    }
    
    @objc func audioRouteChanged(notification:Notification) -> Void {
        print("audioRouteChanged\n")
        print("\(notification.userInfo)")
    }
    //将AudioSession设回Playback，否则播放结束后会断开Ariplay连接，这导致
    //录音结束后播放不会自动连到Airplay。
    func _setAudioSessionToPlayBack() ->Void {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        } catch {
            print("setCtegory failed\n")
        }
    }
    
    //MARK Actions
    
    @IBAction func play(_ sender: UIButton) {
        print("\(AVAudioSession.sharedInstance())")
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try player = AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "time_zero", withExtension: "mp3", subdirectory: "SFX")!)
            player.delegate = self
            
            player.play()
            
            playing = true
            hintLabel.text = "Airing to GT"
            micButton.setTitle("...", for: .normal)
            longPressGestureRcongnizer.isEnabled = false
            micButton.isEnabled = false
            
        } catch {
            print("init player error \(error)\n")
        }
    }
    @IBAction func recordAndPlay(_ sender: UILongPressGestureRecognizer) {
        print("\(AVAudioSession.sharedInstance().currentRoute)\n")
        if sender.state == .began {
            let settings = Dictionary(dictionaryLiteral: (AVSampleRateKey, NSNumber(value: 44100.0)), (AVFormatIDKey, NSNumber(value: kAudioFormatMPEG4AAC)), (AVNumberOfChannelsKey, NSNumber(value: 1)), (AVEncoderAudioQualityKey, NSNumber(value: kAudioConverterQuality_Max)))
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
                try recorder = AVAudioRecorder(url: filePath, settings: settings)
            } catch {
                print("cannot init recorder \(error.localizedDescription)\n")
                hintLabel.text = "Fail to recorder"
                recording = false;
                return
            }
            recorder.delegate = self
            recorder.record()
            
            recording = true
            hintLabel.text = "Release to send"
        } else if sender.state == .ended {
            if recording {
                recorder.stop()
                recording = false
            } else {
                hintLabel.text = "Press me to speak"
                _setAudioSessionToPlayBack()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func avAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        //print("\(audioSession.availableCategories)\n")
        do {
            audioSession.requestRecordPermission({_ in print("ok\n")})
            try audioSession.setActive(true)
        } catch {
            print("xxx\n")
        }
    }
    
    //#MARK AVAudioRecorderDelegate
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("audioRecorderEncodeErrorDidOccur\n")
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("audioRecorderDidFinishRecording\n")
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try player = AVAudioPlayer(contentsOf: self.recorder.url)
            player.delegate = self
            
            player.play()
            
            playing = true
            hintLabel.text = "Airing to GT"
            micButton.setTitle("...", for: .normal)
            longPressGestureRcongnizer.isEnabled = false
            micButton.isEnabled = false
            
        } catch {
            print("init player error \(error)\n")
        }

    }
    
    //#MARK AVAudioPlayerDelegate
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("audioPlayerDecodeErrorDidOccur\n")
        playing = false
        micButton.setTitle("Micro", for: .normal)
        longPressGestureRcongnizer.isEnabled = true
        micButton.isEnabled = true
        hintLabel.text = "Press me to speak"
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("audioPlayerDidFinishPlaying\n")
        
        _setAudioSessionToPlayBack()
        
        playing = false
        micButton.setTitle("Micro", for: .normal)
        longPressGestureRcongnizer.isEnabled = true
        micButton.isEnabled = true
        hintLabel.text = "Press me to speak"
    }
    
}*/
