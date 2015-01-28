//
//  Task.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/28.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

class Task: NSObject {
    var taskId: Int
    var title: String
    var text: String
    var completed: Bool
    var costWorkTimes: Int
    var date: NSDate
    
    override init() {

        self.taskId = 0
        self.title = ""
        self.text = ""
        self.completed = false
        self.costWorkTimes = 0
        self.date = NSDate()
        
        super.init()
    }
}
