//
//  StatisticsLocker.swift
//  WorkAndRest
//
//  Created by YangCun on 15/3/5.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

protocol StatisticsLockerDelegate {
    func statisticsLockerDidClickedBuyButton(sender: StatisticsLocker)
}
class StatisticsLocker: UIView {

    var delegate: StatisticsLockerDelegate?
    
    @IBOutlet var view: UIView!
    @IBOutlet var lockTitle: UILabel!
    @IBOutlet var lockSubTitle: UILabel!
    @IBOutlet var buyButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        NSBundle.mainBundle().loadNibNamed("StatisticsLocker", owner: self, options: nil)
        self.addSubview(self.view)
        
        self.lockTitle.text = NSLocalizedString("Chart Functionality Locked", comment: "")
        self.lockSubTitle.text = NSLocalizedString("To unlock, please", comment: "")
        self.buyButton.setTitle(NSLocalizedString("Purchase Pro", comment: ""), forState: UIControlState.Normal)
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
        print("buy")
        self.delegate?.statisticsLockerDidClickedBuyButton(self)
    }
}
