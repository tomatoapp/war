//
//  TableViewHeader.swift
//  WorkAndRest
//
//  Created by Carl.Yang on 7/28/15.
//  Copyright (c) 2015 YangCun. All rights reserved.
//

import UIKit


class TableViewHeader: UIView, NSCopying {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    let DEFAULT_MINUTE = "25"
    let DEFAULT_SECOND = "00"
    
    var contentView: UIView?
    var colonImage: UIImageView?
    var minuteLabel: UILabel?
    var secondLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupContentView()
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupContentView() {
        contentView = UIView(frame: self.frame)
        contentView?.backgroundColor = UIColor.whiteColor()
        self.addSubview(contentView!)
        
        colonImage = UIImageView(image: UIImage(named: "timer_dot"))
        contentView!.addSubview(colonImage!)
        colonImage?.sizeToFit()
        colonImage!.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.contentView!.mas_centerX)
            make.centerY.equalTo()(self.contentView!.mas_centerY)
        }
        
        minuteLabel = UILabel()
        minuteLabel?.font = UIFont(name: "HelveticaNeue-UltraLight", size: 73.0)
        minuteLabel?.text = DEFAULT_MINUTE
        contentView!.addSubview(minuteLabel!)
        minuteLabel?.mas_makeConstraints({ (make) -> Void in
            make.centerY.equalTo()(self.contentView!.mas_centerY)
            make.right.mas_equalTo()(self.colonImage!.mas_left).offset()(-10)
        })
        
        secondLabel = UILabel()
        secondLabel?.font = UIFont(name: "HelveticaNeue-UltraLight", size: 73.0)
        secondLabel?.text = DEFAULT_SECOND
        contentView!.addSubview(secondLabel!)
        secondLabel?.mas_makeConstraints({ (make) -> Void in
            make.centerY.equalTo()(self.contentView!.mas_centerY)
            make.left.mas_equalTo()(self.colonImage!.mas_right).offset()(10)
        })
    }
    
    func moveOutContentView() {
        var newFrame: CGRect! = self.contentView?.frame
        newFrame.origin.y -= newFrame.height
        self.contentView?.frame = newFrame
    }
    
    func moveCenterContentView() {
        self.contentView?.frame = self.frame
    }
    
    
    override func copy() -> AnyObject {
        if let asCopying = (self as AnyObject) as? NSCopying {
            return asCopying.copyWithZone(nil)
        } else {
            return 0
        }
    }
    
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let newTableViewHeader = TableViewHeader(frame: self.frame)
        newTableViewHeader.minuteLabel?.text = self.minuteLabel?.text
        newTableViewHeader.secondLabel?.text = self.secondLabel?.text
        return newTableViewHeader
    }
    
    func updateTime(minutes: String, seconds: String) {
        self.minuteLabel!.text = minutes
        self.secondLabel!.text = seconds
    }
}
