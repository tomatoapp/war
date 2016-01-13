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
        /*
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.workTime = dateFormater.dateFromString("2015-1-20 12:12:12")!
        */
        self.isFinished = false
        super.init()
    }
    
//    func description() -> String {
//        return ""
//    }
    
    override var description: String {
        get {
            return "id: \(self.workId) taskId: \(self.taskId) time: \(self.workTime)"
        }
    }
}
