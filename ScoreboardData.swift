//
//  ScoreboardData.swift
//  GameTimer
//
//  Created by devel on 16/9/20.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import Foundation
struct ScoreboardData {
    enum Poss:String {
        case home = "H", guest = "G", NONE = "N"
    }
    
    let hostScore:Int
    let guestScore:Int
    let time:String
    let period:Int
    let poss:Poss
    let bonus:Poss
    
    init?(json:[String:Any]) {
        print("ScorboardData \(json)\n")
        guard let hscore = json["host"] as? Int,
            let gscroe = json["guest"] as? Int,
            let time = json["time"] as? String,
            let period = json["period"] as? Int,
            let pos = json["poss"] as? String,
            let bonus = json["bonus"] as? String
            else {
                return nil
        }
        hostScore = hscore
        guestScore = gscroe
        self.time = time
        self.period = period
        self.poss = Poss(rawValue:pos)!
        self.bonus = Poss(rawValue: bonus)!
        
    }
}
