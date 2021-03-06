//
//  Task.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/28.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

class Task: NSObject, NSCopying {
    var taskId: Int
    var title: String
    var text: String
    var completed: Bool
    var date: NSDate
    var lastUpdateTime: NSDate
    var minutes: Int
    var expect_times: Int
    var finished_times: Int
    var break_times: Int
    var completedTime : NSDate

    override init() {

        self.taskId = -1
        self.title = ""
        self.text = ""
        self.completed = false
        self.date = NSDate()
        self.lastUpdateTime = NSDate()
        self.minutes = 0
        self.expect_times = 0
        self.finished_times = 0
        self.break_times = 0
        self.completedTime = NSDate(timeIntervalSince1970: 0)
        super.init()
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = Task()
        copy.taskId = self.taskId
        copy.title = self.title
        copy.text = self.text
        copy.completed = self.completed
        copy.date = self.date
        copy.lastUpdateTime = self.lastUpdateTime
        copy.minutes = self.minutes
        copy.expect_times = self.expect_times
        copy.finished_times = self.finished_times
        copy.break_times = self.break_times
        copy.completedTime = self.completedTime
        return copy
    }
    
    
    func getMinutes() -> Int {
        return self.minutes
    }
    
    func getSeconds() -> Int {
        return self.minutes * 60
    }
    
    func getTimerMinutesString() -> String {
        return String(format: "%02d", self.getSeconds() % 3600 / 60)
    }
    
    func getTimerSecondsString() -> String {
        return String(format: "%02d", self.getSeconds() % 3600 % 60)
    }
    
}
