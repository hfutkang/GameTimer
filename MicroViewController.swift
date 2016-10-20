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
    
    /*class PlayerState: AnyObject {
        let basicDes:AudioStreamBasicDescription
        var queue:AudioQueueRef? = nil
        var buffers = [AudioQueueBufferRef]()
        var mAudioFile:AudioFileID
        var bufferByteSize:UInt32 = 0
        var mCurrentPackets:Int64
        var mNumPacketsToRead:UInt32
        var mPacketDescs:AudioStreamPacketDescription
        init() {
            basicDes = AudioStreamBasicDescription(mSampleRate: 44100.0, mFormatID: kAudioFormatLinearPCM, mFormatFlags: kLinearPCMFormatFlagIsAlignedHigh|kLinearPCMFormatFlagIsSignedInteger|kLinearPCMFormatFlagIsPacked, mBytesPerPacket: 4, mFramesPerPacket: 1, mBytesPerFrame: 4, mChannelsPerFrame: 2, mBitsPerChannel: 16, mReserved: 0)
        }
    }*/
    
    //MARK Attributes
    var userData = RecorderState()
    static var mUdpSocket:GCDAsyncUdpSocket?
    //MARK Outlets
    @IBOutlet weak var speak: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _initVolumeView()
        MicroViewController.mUdpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        MicroViewController.mUdpSocket = nil
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
    
    //MARK Action
    
    @IBAction func speak(_ sender: UIButton) {
        if !userData.recording {
            userData.recording = true
            speak.setTitle("Over", for: .normal)
            initAudioInputQueue()
            AudioQueueStart(userData.queue!, nil)
        } else {
            AudioQueueStop(userData.queue!, true)
            userData.recording = false
            print("stoped\n")
            speak.setTitle("Start speak", for: .normal)
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
