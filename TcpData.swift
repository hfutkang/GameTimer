//
//  TcpData.swift
//  GameTimer
//
//  Created by devel on 16/9/19.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import Foundation

class TcpData {
    let head:UInt8 = 0x5c
    var cmd:UInt8
    var len:UInt8
    var data:Data
    init(command:UInt8, length:UInt8, data:Data) {
        self.cmd = command
        self.len = length
        self.data = data
    }
    
    func getData() -> Data {
        var data = Data()
        data.append(head)
        data.append(cmd)
        data.append(len)
        data.append(data)
        return data
    }
}
