//
//  StatisticsLocker.swift
//  WorkAndRest
//
//  Created by YangCun on 15/3/5.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

class StatisticsLocker: UIView {

    @IBOutlet var view: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        NSBundle.mainBundle().loadNibNamed("StatisticsLocker", owner: self, options: nil)
        self.addSubview(self.view)
    }

    func updateViewsWidth() {
        if self.view.frame.size.width != self.frame.size.width {
            self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.frame.size.width, self.view.frame.size.height)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateViewsWidth()
    }
    
    @IBAction func buyButtonClicked(sender: AnyObject) {
        println("buy")
    }
}
