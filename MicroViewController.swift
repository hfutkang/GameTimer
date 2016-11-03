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

class MicroViewController: UIViewController,AVAudioPlayerDelegate,GCDAsyncUdpSocketDelegate {
    
    class RecorderState:AnyObject {
        var basicDes:AudioStreamBasicDescription
        var queue:AudioQueueRef? = nil
        var buffers = [AudioQueueBufferRef]()
        var mAudioFile:AudioFileID? = nil
        var bufferByteSize:UInt32 = 0
        var recording = false
        var inPackets:Int64 = 0
        
        init() {
            basicDes = AudioStreamBasicDescription(mSampleRate: 44100, mFormatID: kAudioFormatLinearPCM, mFormatFlags: kLinearPCMFormatFlagIsAlignedHigh|kLinearPCMFormatFlagIsSignedInteger|kLinearPCMFormatFlagIsPacked, mBytesPerPacket: 4, mFramesPerPacket: 1, mBytesPerFrame: 4, mChannelsPerFrame: 2, mBitsPerChannel: 16, mReserved: 0)
        }
    }
    
    //MARK Attributes
    var userData = RecorderState()
    static var mUdpSocket:GCDAsyncUdpSocket?
    //MARK Outlets
    @IBOutlet weak var speak: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //_initVolumeView()
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 20/255.0, green: 23/255.0, blue: 35/255.0, alpha: 1)
        
        self.tabBarController?.tabBar.isTranslucent = false
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 20/255.0, green: 23/255.0, blue: 35/255.0, alpha: 1)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        MicroViewController.mUdpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        _initAvSession()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopMic()
        MicroViewController.mUdpSocket?.close()
        MicroViewController.mUdpSocket = nil
        
        _deinitAvSession()
        
    }
    func  _initVolumeView() -> Void {
        
        let vv = MPVolumeView(frame: CGRect(x: 30, y: 50, width: self.view.frame.width - 50, height: 30))
        vv.sizeToFit()
        vv.showsRouteButton = true
        vv.showsVolumeSlider = true
        self.view.addSubview(vv)
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
    
    func initAudioInputQueue() {
        print("\(userData.basicDes)\n")
        let code = AudioQueueNewInput(&userData.basicDes, audioQueueCallback, &userData, nil, nil, 0, &userData.queue)
        print("\(code)\n")
        var desSize = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
        if userData.queue == nil {
            print("queue is nil\n")
        } else {
            print("\(userData.queue!)\n")
        }
        AudioQueueGetProperty(userData.queue!, kAudioQueueProperty_StreamDescription, &userData.basicDes, &desSize)
        deriveBufferSize(queue: userData.queue!, des: &userData.basicDes, seconds: 0.01, bufferSize: &userData.bufferByteSize)
        print("\(userData.bufferByteSize)\n")
        for i in 0...2 {
            var buffer:AudioQueueBufferRef?
            let code = AudioQueueAllocateBuffer(userData.queue!, userData.bufferByteSize, &buffer)
            
            print("\(code)\n")
            AudioQueueEnqueueBuffer(userData.queue!, buffer!, 0, nil)
            userData.buffers.append(buffer!)
        }
        AudioQueueSetParameter(userData.queue!, kAudioQueueParam_Volume, 0.3)
        
    }
    
    //设置buffer大小
    func deriveBufferSize(queue: AudioQueueRef, des: UnsafePointer<AudioStreamBasicDescription>, seconds: Float64, bufferSize: UnsafeMutablePointer<UInt32>) {
        let maxBufferSize = 1024
        var maxPacketSize = des.pointee.mBytesPerPacket
        if maxPacketSize == 0 {
            var maxVBRPacketSize = UInt32(MemoryLayout<UInt32>.size)
            AudioQueueGetProperty(queue, kAudioQueueProperty_MaximumOutputPacketSize, &maxPacketSize, &maxVBRPacketSize)
            
        }
        let numBytesForTime:Float64 = des.pointee.mSampleRate * Float64(maxPacketSize) * seconds
        if numBytesForTime < Float64(maxPacketSize) {
            bufferSize.pointee = UInt32(numBytesForTime)
        } else {
            bufferSize.pointee = UInt32(maxBufferSize)
        }
        
        print("buffer size :\(numBytesForTime) \(bufferSize.pointee)\n")
    }
    
    func stopMic() {
        if userData.recording == true {
            AudioQueueStop(userData.queue!, true)
            userData.recording = false
            print("stopped\n")
            speak.setTitle("Start speak", for: .normal)
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:"sctek.cn.MGameTimer.mic"), object: nil)
            
            if TcpConnection.sharedInstance.isConnected() {
                let msg = "{\"cmd\":\"mic\",\"value\":\"0\"}"
                TcpConnection.sharedInstance.send(data: msg.data(using: .utf8)!, tag: 1)
            }
        }
    }
    
    //MARK objc
    @objc func onReceiveDataForDevice(sender:Notification) {
        let result = sender.userInfo?["result"] as! String

        if result == "ok" {
            userData.recording = true
            speak.setTitle("Over", for: .normal)
            initAudioInputQueue()
            AudioQueueStart(userData.queue!, nil)
        } else {
            print("mic is buzy now\n")
        }
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
    
    //Audio queue service input callback
    let audioQueueCallback:AudioQueueInputCallback = {
        (inUserData, inAQ, inBuffer, inStartTime, inNumberPackets, inPacketDescs) in
        print("AudioQueueInputCallback\n")
        let data:UnsafeMutableRawPointer = inBuffer.pointee.mAudioData
        let dataSize = Int(inBuffer.pointee.mAudioDataByteSize)
        let userD = Unmanaged<RecorderState>.fromOpaque(inUserData!).takeUnretainedValue()
        var inNumPackets = inNumberPackets
        
        let i8s = UnsafeBufferPointer(start: data.assumingMemoryBound(to: UInt8.self), count: dataSize)
        let cc = Data(buffer: i8s)
        print("data bytes:\(dataSize)\n")
        //TcpConnection.sharedInstance.send(data: cc, tag: 0)
        MicroViewController.mUdpSocket?.send(cc, toHost: "192.168.222.254", port: 7072, withTimeout: 1.0, tag: 0)
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, nil)
    }

    
    /*let audioOutQueueCallback:AudioQueueOutputCallback = {(inUserData, outQueue, outBuffer) in
        
    }*/
    
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
