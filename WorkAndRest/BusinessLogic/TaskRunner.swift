//
//  TaskRunner.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/1.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

protocol TaskRunnerDelegate {
    func completed(sender: TaskRunner?)
    func breaked(sender: TaskRunner?)
    func tick(sender: TaskRunner?)
}


class TaskRunner: NSObject, UIAlertViewDelegate {
    
    var delegate: TaskRunnerDelegate?
    var taskItem: Task!
    var seconds = 0

    var isWorking = false
    var timer: NSTimer!
    
    override init() {
        super.init()
    }
    
    convenience init(task: Task!, seconds:Int) {
        self.init()
        self.taskItem = task
        self.seconds = seconds

    }
    
    // MARK: - Methods
    
     func start() {
        self.isWorking = true
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("tick"), userInfo: nil, repeats: true)
    }
    
     func stop() {
        self.reset()
        self.delegate?.breaked(self)
    }
    
    // MARK: - Private Methods

    func tick() {
        if self.seconds > 0 {
            self.seconds--
            self.delegate?.tick(self)
        } else {
            self.isWorking = false
            self.cancelTimer()
            self.completedOneWorkTime()
            self.delegate?.completed(self)
        }
    }
    
    func cancelTimer() {
        self.timer.invalidate()
    }
    
    func completedOneWorkTime() {
        self.taskItem.costWorkTimes = self.taskItem.costWorkTimes++
        DBOperate.updateTask(self.taskItem)
    }
    
    func reset() {
        self.cancelTimer()
        self.isWorking = false
    }
}