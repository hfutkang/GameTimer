//
//  ModeCheckUtils.swift
//  GameTimer
//
//  Created by devel on 16/11/7.
//  Copyright © 2016年 Sctek. All rights reserved.
//

//做权限检查的工具类
import Foundation
class ModeCheckUtils {
    static func isPrimary() -> Bool {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.privilegeMask == 0xFF
    }
    
    static func canPlayMusic() -> Bool {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.privilegeMask & 0x08 != 0x00
    }
    
    static func canControlScoreboard() -> Bool {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.privilegeMask & 0x01 != 0x00
    }
    
    static func canPlaySFX() -> Bool {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.privilegeMask & 0x04 != 0x00
    }
    
    static func canControlMic() -> Bool {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.privilegeMask & 0x02 != 0x00
    }
}
