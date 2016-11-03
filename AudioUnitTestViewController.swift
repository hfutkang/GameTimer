//
//  AudioUnitTestViewController.swift
//  GameTimer
//
//  Created by devel on 16/11/2.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import AudioToolbox
import CoreAudioKit
import AudioUnit
class AudioUnitTestViewController: UIViewController {
    
    var userData = UserData()
    var recording = false
    
    class UserData: AnyObject {
        var audioUnit:AudioUnit? = nil
        var grap:AUGraph? = nil
    }
    
    override func viewDidLoad() {
        //_initAvSession()
        iniAUGrap()
        initAudioUnit()
        let status = AUGraphInitialize(userData.grap!)
        print("AudioUnit AUGraphInitialize \(status)\n")
        MicroViewController.mUdpSocket = GCDAsyncUdpSocket(delegate: nil, delegateQueue: DispatchQueue.main)
    }
    
    @IBAction func record(_ sender: UIButton) {
        if !recording {
            startGrap()
            sender.setTitle("Stop", for: .normal)
            let msg = "{\"cmd\":\"mic\",\"value\":\"1\"}"
            TcpConnection.sharedInstance.send(data: msg.data(using: .utf8)!, tag: 0)
            
        } else {
            stopGrap()
            //AudioOutputUnitStop(userData.audioUnit!)
            sender.setTitle("Record", for: .normal)
            let msg = "{\"cmd\":\"mic\",\"value\":\"0\"}"
            TcpConnection.sharedInstance.send(data: msg.data(using: .utf8)!, tag: 0)
        }
        recording = !recording
    }
    
    
    func _initAvSession() -> Void {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setPreferredSampleRate(44100.0)
            try session.setActive(true)
        } catch {
            print("\(error)\n")
        }
    }
    
    func _deinitAvSession() -> Void {
        print("_deinitAvSession\n")
        let seesion = AVAudioSession.sharedInstance()
        do {
            try seesion.setActive(false)
        } catch {
            print("\(error)\n")
        }
    }
    
    func startGrap() {
        
        let status = AUGraphStart(userData.grap!)
        print("AudioUnit AUGraphStart \(status)\n")
        
    }
    
    func stopGrap() -> Void {
        let status = AUGraphStop(userData.grap!)
        print("AudioUnit AUGraphStop \(status)\n")
    }
    
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
    
    func initAudioUnit() -> Void {
        print("initAudioUnit\n")
        
        var enable:UInt32 = 1
        var status = AudioUnitSetProperty(userData.audioUnit!, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &enable, UInt32(MemoryLayout<UInt32>.size))
        print("AudioUnit AudioUnitSetProperty enable \(status)\n")
        
        var basicDes = AudioStreamBasicDescription(mSampleRate: 44100, mFormatID: kAudioFormatLinearPCM, mFormatFlags: kLinearPCMFormatFlagIsSignedInteger|kLinearPCMFormatFlagIsPacked, mBytesPerPacket: 4, mFramesPerPacket: 1, mBytesPerFrame: 4, mChannelsPerFrame: 2, mBitsPerChannel: 16, mReserved: 0)
        
        status = AudioUnitSetProperty(userData.audioUnit!, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &basicDes, UInt32(MemoryLayout<AudioStreamBasicDescription>.size))
        print("AudioUnit AudioUnitSetProperty format \(status)\n")
        
        var callbackStruct = AURenderCallbackStruct(inputProc: audioUnitInputCallback, inputProcRefCon: &userData)
        status = AudioUnitSetProperty(userData.audioUnit!, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, 0, &callbackStruct, UInt32(MemoryLayout<AURenderCallbackStruct>.size))
        print("AudioUnit AudioUnitSetProperty callback \(status)\n")
        
    }
    
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

}
