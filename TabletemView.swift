//
//  TabItemView.swift
//  GameTimer
//
//  Created by devel on 16/9/26.
//  Copyright © 2016年 Sctek. All rights reserved.
//

import UIKit
class TableItemView: UIView {
    
    var nameLabel:UILabel
    var line:UIView
    
    override init(frame: CGRect) {
        print("11111111111111111")
        self.nameLabel = UILabel(frame:frame)
        self.nameLabel.text = "Home"
        self.nameLabel.textAlignment = .center
        self.line = UIView()
        line.backgroundColor = UIColor.blue
        super.init(frame: frame)
        _layoutSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        print("222222222222222222")
        self.nameLabel = UILabel()
        self.nameLabel.text = "Home"
        self.nameLabel.textAlignment = .center
        self.line = UIView()
        line.backgroundColor = UIColor.blue
        super.init(coder: aDecoder)
        addSubview(nameLabel)
        //_layoutSubView()
    }
    
    func _layoutSubView() -> Void {
        print("_layoutSubView")
        addSubview(nameLabel)
        //addSubview(line)
        
        //for nameLable
        self.addConstraint(NSLayoutConstraint(item: self.nameLabel, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
        
        self.addConstraint(NSLayoutConstraint(item: self.nameLabel, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))
        
        self.addConstraint(NSLayoutConstraint(item: self.nameLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        
        self.addConstraint(NSLayoutConstraint(item: self.nameLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        
        //for line
        /*self.addConstraint(NSLayoutConstraint(item: self.line, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        
        self.addConstraint(NSLayoutConstraint(item: self.line, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        
        self.addConstraint(NSLayoutConstraint(item: self.line, attribute: .top, relatedBy: .equal, toItem: self.nameLabel, attribute: .bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.line, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute(rawValue: 0)!, multiplier: 1, constant: 1))
         */
        
    }
    
}
