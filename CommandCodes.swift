//
//  ButtonCodes.swift
//  GameTimer
//
//  Created by devel on 16/9/19.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import Foundation
class CommandCodes {
    static let CMD_HEADER:UInt8 = 0x5c
    //命令类型（比如按键命令等）
    static let CMD_TYPE_BUTTON:UInt8 = 0x01
    static let CMD_TYPE_SET_TIMER:UInt8 = 0x02
    
    //按键命令的键值
    static let CMD_TIMER_SET:UInt8 = 0x01
    static let CMD_TIMER_START:UInt8 = 0x02
    static let CMD_TIMER_STOP:UInt8 = 0x03
    static let CMD_TIMER_PLAY:UInt8 = 0x01
    static let CMD_PERIOD_ADD:UInt8 = 0x0b
    static let CMD_PERIOD_SUB:UInt8 = 0x0c
    static let CMD_HOME_POSS:UInt8 = 0x08
    static let CMD_GUEST_POSS:UInt8 = 0x14
    static let CMD_BUZZER:UInt8 = 0x08
    static let CMD_HOME_SCORE_UP:UInt8 = 0x06
    static let CMD_HOME_SCORE_DOWN:UInt8 = 0x07
    static let CMD_GUEST_SCORE_UP:UInt8 = 0x12
    static let CMD_GUEST_SCORE_DOWN:UInt8 = 0x13
    static let CMD_HOME_BUNUS:UInt8 = 0x09
    static let CMD_GUEST_BUNUS:UInt8 = 0x15
    static let CMD_RESET_SCORE:UInt8 = 0x09
    static let CMD_RESET_TIMER:UInt8 = 0x10
    static let CMD_BUZZER_MUTE_ON = 0x16
    static let CMD_BUZZER_MUTE_OFF = 0x17
    static let CMD_TIMER_COUNT_UP = 0x18
    static let CMD_TIMER_COUNT_DOWN = 0x19
    static let CMD_BUZZERONLY_ON = 0x1a
    static let CMD_BUZZERONLY_OFF = 0x1b
    
    class func compositeDataFor(command:UInt8, length:UInt8, data:Data) -> Data {
        var tempData = Data()
        tempData.append(CMD_HEADER)
        tempData.append(command)
        tempData.append(length)
        tempData.append(data)
        return tempData
    }
    
}
