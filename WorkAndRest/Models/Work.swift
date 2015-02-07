//
//  Work.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/26.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

class Work: NSObject {
    var workId: Int
    var taskId: Int
    var workTime: NSDate
    var isFinished: Bool
    
    override init() {
        self.workId = 0
        self.taskId = 0
        self.workTime = NSDate()
        self.isFinished = false
        super.init()
    }
}
