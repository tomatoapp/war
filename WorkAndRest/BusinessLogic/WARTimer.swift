//
//  WARTimer.swift
//  WorkAndRest
//
//  Created by Carl.Yang on 8/6/15.
//  Copyright (c) 2015 YangCun. All rights reserved.
//

import UIKit

class WARTimer: NSObject {
    
    var seconds: WARSecond = WARSecond(25 * 60)
    var timer: NSTimer?
    var selector: Selector?
    
    override init() {
        super.init()
    }
    
    /**
    
    */
//    convenience init(seconds: Int) {
//        self.init()
//        self.seconds = seconds
//    }
    
    /**
    Setup the timer
    */
//    func setup(seconds: Int) {
//        self.seconds = seconds
//    }
    
    /**
    Start the timer
    */
    func start() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0,
            target: self,
            selector: Selector("tick"),
            userInfo: nil,
            repeats: true)
    }
    
    typealias WARTimerTickBlock = (seconds: WARSecond) -> ()
    var block: WARTimerTickBlock?
    
    func startWithTickBlock(block: WARTimerTickBlock) {
        self.start()
        self.block = block
    }
    
    /**
    Tick
    */
    func tick() {
        self.seconds--
        self.block!(seconds: self.seconds)
//        println("tick: \(self.seconds)")
        if self.seconds == WARSecond.zero() {
            self.cancle()
        }
    }
    
    /**
    Cancle the timer
    */
    func cancle() {
        self.timer?.invalidate()
    }
   
}
