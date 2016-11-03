//
//  TcpConnection.swift
//  GameTimer
//
//  Created by devel on 16/9/19.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import Foundation
let address = "192.168.222.1"
let port:UInt16 = 0x8888
class TcpConnection {
    
    static let sharedInstance:TcpConnection = {
        let instance = TcpConnection()
        return instance
    }()
    
    var tcpSocket:GCDAsyncSocket
    
    init() {
        tcpSocket = GCDAsyncSocket(delegate: nil, delegateQueue: DispatchQueue.main)
    }
    
    //#MARK funs
    func connect(host:String, port:UInt16) -> Bool {
        do {
            try tcpSocket.connect(toHost: host, onPort: port, withTimeout:5)
        } catch {
            print("error connect to \(host)\n")
            return false
        }
        return true
    }
    
    func setDelegate(delegate:GCDAsyncSocketDelegate) {
        tcpSocket.delegate = delegate
    }
    
    func isConnected() -> Bool {
        return tcpSocket.isConnected
    }
    
    func send(data: Data, tag: Int) -> Void {
        tcpSocket.write(data, withTimeout: -1  , tag: tag)
    }
}
