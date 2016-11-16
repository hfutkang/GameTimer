//
//  MicroViewController.swift
//  GameTimer
//
//  Created by devel on 16/10/11.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import AudioToolbox
import CoreAudioKit
import AudioUnit

class MicroViewController: UIViewController,AVAudioPlayerDelegate,GCDAsyncUdpSocketDelegate {
    
    class UserData: AnyObject {
        var audioUnit:AudioUnit? = nil
        var grap:AUGraph? = nil
        var recording = false
    }
    
    //MARK Attributes
    var userData = UserData()
    static var mUdpSocket:GCDAsyncUdpSocket?
    //MARK Outlets
    @IBOutlet weak var speak: UIButton!
    @IBOutlet var accessView: UIView!
    
    @IBOutlet weak var volumeSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //_initVolumeView()
        print("MicroViewController viewDidLoad\n")
        
        iniAUGrap()
        initAudioUnit()
        
        //设置导航栏背景
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 20/255.0, green: 23/255.0, blue: 35/255.0, alpha: 1)
        
        //设置Tabbar背景
        self.tabBarController?.tabBar.isTranslucent = false
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 20/255.0, green: 23/255.0, blue: 35/255.0, alpha: 1)
        
        speak.setImage(#imageLiteral(resourceName: "icon_mic_normal"), for: .normal)
        speak.setImage(#imageLiteral(resourceName: "icon_mic_clicked"), for: .highlighted)
        
        NotificationCenter.default.addObserver(self, selector: #selector(getVolumeFromDevice(sender:)), name: NSNotification.Name("sctek.cn.MGameTimer.volume"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        MicroViewController.mUdpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        accessView.isHidden = ModeCheckUtils.canControlMic()
        if ModeCheckUtils.canControlMic() {
            let msg = "{\"cmd\":\"getVolume\"}"
            TcpConnection.sharedInstance.send(data: msg.data(using: .utf8)!, tag: 0)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopMic()
        MicroViewController.mUdpSocket?.close()
        MicroViewController.mUdpSocket = nil
    }
    
    func  _initVolumeView() -> Void {
        
        let vv = MPVolumeView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        vv.showsRouteButton = true
        vv.showsVolumeSlider = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: vv)
        //self.view.addSubview(vv)
    }
    
    func _initAvSession() -> Void {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setActive(true)
        } catch {
            print("\(error)\n")
        }
    }
    
    func _deinitAvSession() -> Void {
        let seesion = AVAudioSession.sharedInstance()
        do {
            try seesion.setActive(false)
        } catch {
            print("\(error)\n")
        }
    }
    
    
    func stopMic() {
        if userData.recording == true {
            userData.recording = false
            print("stopped\n")
            speak.isHighlighted = false
            stopGrap()
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:"sctek.cn.MGameTimer.mic"), object: nil)
            
            if TcpConnection.sharedInstance.isConnected() {
                let msg = "{\"cmd\":\"mic\",\"value\":\"0\"}"
                TcpConnection.sharedInstance.send(data: msg.data(using: .utf8)!, tag: 1)
            }
        }
    }
    
    //启动AUGraph，开始录音
    func startGrap() {
        let status = AUGraphStart(userData.grap!)
        print("AudioUnit AUGraphStart \(status)\n")
        
    }
    
    //停止录音
    func stopGrap() -> Void {
        let status = AUGraphStop(userData.grap!)
        print("AudioUnit AUGraphStop \(status)\n")
    }
    
    //初始化AUGraph
    func iniAUGrap() {
        var status = NewAUGraph(&userData.grap)
        print("AudioUnit NewAUGraph \(status)\n")
        
        var acd = AudioComponentDescription(componentType: kAudioUnitType_Output, componentSubType: kAudioUnitSubType_VoiceProcessingIO, componentManufacturer: kAudioUnitManufacturer_Apple, componentFlags: 0, componentFlagsMask: 0)
        
        var auNode = AUNode(bigEndian: 1)
        status = AUGraphAddNode(userData.grap!, &acd, &auNode)
        print("AudioUnit AUGraphAddNode \(status)\n")
        
        status = AUGraphOpen(userData.grap!)
        print("AudioUnit AUGraphOpen \(status)\n")
        
        status = AUGraphNodeInfo(userData.grap!, auNode, &acd, &userData.audioUnit)
        print("AudioUnit AUGraphNodeInfo \(status)\n")
        
    }
    
    //初始化AudioUnit
    func initAudioUnit() -> Void {
        print("initAudioUnit\n")
        
        var enable:UInt32 = 1
        var status = AudioUnitSetProperty(userData.audioUnit!, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &enable, UInt32(MemoryLayout<UInt32>.size))
        print("AudioUnit AudioUnitSetProperty enable \(status)\n")
        
        var basicDes = AudioStreamBasicDescription(mSampleRate: 44100, mFormatID: kAudioFormatLinearPCM, mFormatFlags: kLinearPCMFormatFlagIsSignedInteger|kLinearPCMFormatFlagIsPacked, mBytesPerPacket: 4, mFramesPerPacket: 1, mBytesPerFrame: 4, mChannelsPerFrame: 2, mBitsPerChannel: 16, mReserved: 0)
        
        //设置音频数据参数
        status = AudioUnitSetProperty(userData.audioUnit!, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &basicDes, UInt32(MemoryLayout<AudioStreamBasicDescription>.size))
        print("AudioUnit AudioUnitSetProperty format \(status)\n")
        
        var callbackStruct = AURenderCallbackStruct(inputProc: audioUnitInputCallback, inputProcRefCon: &userData)
        status = AudioUnitSetProperty(userData.audioUnit!, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, 0, &callbackStruct, UInt32(MemoryLayout<AURenderCallbackStruct>.size))
        print("AudioUnit AudioUnitSetProperty callback \(status)\n")
        
        status = AUGraphInitialize(userData.grap!)
        print("AudioUnit AUGraphInitialize \(status)\n")
    }
    
    //Audiounit输入回调，在这里获取pcm数据。
    let audioUnitInputCallback:AURenderCallback = {
        (inRefCon: UnsafeMutableRawPointer, ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>, inTimeStamp: UnsafePointer<AudioTimeStamp>, inBusNumber: UInt32, inNumberFrames: UInt32, ioData: UnsafeMutablePointer<AudioBufferList>?) in
        print("AudioUnit AURenderCallback \(inBusNumber) \(inNumberFrames) \(ioData)\n")
        
        let userD = inRefCon.bindMemory(to: UserData.self, capacity: 1).pointee
        
        let audioBuffer = AudioBuffer(mNumberChannels: 2, mDataByteSize: inNumberFrames*4, mData: nil)
        var bufferList = AudioBufferList(mNumberBuffers: 1, mBuffers: audioBuffer)
        
        AudioUnitRender(userD.audioUnit!, ioActionFlags, inTimeStamp, 1, inNumberFrames, &bufferList)
        let data = bufferList.mBuffers
        
        let i8s = UnsafeBufferPointer(start: data.mData?.assumingMemoryBound(to: UInt8.self), count: Int(data.mDataByteSize))
        let cc = Data(buffer: i8s)
        //print("data bytes:\(abuffer?.mDataByteSize)\n")
        
        MicroViewController.mUdpSocket?.send(cc, toHost: "192.168.222.254", port: 7072, withTimeout: 1.0, tag: 0)
        
        return 0;
    }
    
    //MARK objc
    @objc func onReceiveDataForDevice(sender:Notification) {
        let result = sender.userInfo?["result"] as! String

        if result == "ok" {
            userData.recording = true
            speak.isHighlighted = true
            startGrap()
        } else {
            print("mic is buzy now\n")
        }
    }
    
    @objc func getVolumeFromDevice(sender: Notification) {
        let volume = sender.userInfo?["volume"] as! Int
        volumeSlider.setValue(Float(volume), animated: true)
    }
    
    //MARK Action
    @IBAction func speak(_ sender: UIButton) {
        if !userData.recording {
            if TcpConnection.sharedInstance.isConnected() {
                NotificationCenter.default.addObserver(self, selector: #selector(onReceiveDataForDevice(sender:)), name: NSNotification.Name(rawValue:"sctek.cn.MGameTimer.mic"), object: nil)
                
                let msg = "{\"cmd\":\"mic\",\"value\":\"1\"}"
                TcpConnection.sharedInstance.send(data: msg.data(using: .utf8)!, tag: 0)
            } else {
                print("tcp disconnected\n")
            }
        } else {
            stopMic()
        }
    }
    
    @IBAction func onSliderValueChanged(_ sender: UISlider) {
        print("onSliderValueChanged\n")
        TcpConnection.sharedInstance.send(cmd: "setVolume", value: "\(Int(sender.value))", extra: nil)
    }
    
    
    //MARK GCDAsyncUdpSocketDelegate
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        print("udp didNotConnect\n")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        print("udp didSendDataWithTag\n")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        print("udp didNotSendDataWithTag\n")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        print("udp didReceive data\n")
    }
    
}
