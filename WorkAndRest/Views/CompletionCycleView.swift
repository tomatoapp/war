//
//  CompletionCycleView.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/6.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit
import AVFoundation

protocol CompletionCycleViewDelegate {
    func completionCycleView(sender: CompletionCycleView, didSelectedNumber number: Int)
}

class CompletionCycleView: UIView {

    let MAX_NUMBER = 999
    var delegate: CompletionCycleViewDelegate?
    
    var number = GlobalConstants.DEFAULT_NUMBER
    var timer: NSTimer!
    var isMinusButtonFlag = true
    
    @IBOutlet var view: UIView!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var minusButton: UIButton!
    @IBOutlet var plusButton: UIButton!
    
    @IBAction func plusButtonClick(sender: AnyObject) {
        if number < MAX_NUMBER {
            number += 1
            AudioServicesPlaySystemSound(1103)
            self.refreshView()
            self.delegate?.completionCycleView(self, didSelectedNumber: number)
        }
    }
    
    @IBAction func minusButtonClick(sender: AnyObject) {
        if number > 1 {
            number -= 1
            AudioServicesPlaySystemSound(1103)
            self.refreshView()
            self.delegate?.completionCycleView(self, didSelectedNumber: number)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
        self.refreshView()
        self.minusButton.addTarget(self, action: Selector("buttonDown:"), forControlEvents: UIControlEvents.TouchDown)
        self.minusButton.addTarget(self, action: Selector("buttonUp:"), forControlEvents: UIControlEvents.TouchUpInside | UIControlEvents.TouchUpOutside)
        
        self.plusButton.addTarget(self, action: Selector("buttonDown:"), forControlEvents: UIControlEvents.TouchDown)
        self.plusButton.addTarget(self, action: Selector("buttonUp:"), forControlEvents: UIControlEvents.TouchUpInside | UIControlEvents.TouchUpOutside)
    }
    
    func buttonDown(sender: UIButton!) {
        if sender == self.minusButton {
            self.isMinusButtonFlag = true
        } else if sender == self.plusButton {
            self.isMinusButtonFlag = false
        }
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1,
            target: self,
            selector: Selector("changeNumber"),
            userInfo: nil,
            repeats: true)
    }
    
    func buttonUp(sender: AnyObject) {
        self.timer.invalidate()
    }
    
    func changeNumber() {
        
        if self.isMinusButtonFlag {
            if number > 1 {
                number -= 1
                AudioServicesPlaySystemSound(1103)
                self.refreshView()
                self.delegate?.completionCycleView(self, didSelectedNumber: number)
            }
        } else {
            if number < 999 {
                number += 1
                AudioServicesPlaySystemSound(1103)
                self.refreshView()
                self.delegate?.completionCycleView(self, didSelectedNumber: number)
            }
        }
    }

    func setup() {
        NSBundle.mainBundle().loadNibNamed("CompletionCycleView", owner: self, options: nil)
        self.addSubview(self.view)

        self.view.mas_updateConstraints { make in
            make.width.equalTo()(self.frame.size.width-40)
            make.height.equalTo()(self.frame.size.height)
            make.centerX.equalTo()(self.mas_centerX)
            make.centerY.equalTo()(self.mas_centerY)
            return ()
        }
    }
    
    func refreshView() {
        self.numberLabel.text = "\(number)"
        self.minusButton.enabled = number > 1
        self.plusButton.enabled = number < MAX_NUMBER
    }
}
