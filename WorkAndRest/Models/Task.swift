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
    var costWorkTimes: Int
    var date: NSDate
    var lastUpdateTime: NSDate
    var minutes: Int

    override init() {

        self.taskId = -1
        self.title = ""
        self.text = ""
        self.completed = false
        self.costWorkTimes = 0
        self.date = NSDate()
        self.lastUpdateTime = NSDate()
        self.minutes = 0
        super.init()
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = Task()
        copy.taskId = self.taskId
        copy.title = self.title
        copy.text = self.text
        copy.completed = self.completed
        copy.costWorkTimes = self.costWorkTimes
        copy.date = self.date
        copy.lastUpdateTime = self.lastUpdateTime
        copy.minutes = self.minutes
        return copy
    }
    
    
}
