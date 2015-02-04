//
//  TaskRunnerManager.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/4.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

protocol TaskRunnerManagerDelegate {
    func taskRunnerMangerWillFreezeTask(taskManager: TaskRunnerManager!) -> TaskRunner
    func taskRunnerManger(taskManager: TaskRunnerManager!, didActiveFrozenTaskRunner taskRunner:TaskRunner!)
}

class TaskRunnerManager: NSObject {
    var delegate:TaskRunnerManagerDelegate?
    var taskRunner: TaskRunner?
    
    func freezeTaskManager(taskRunner: TaskRunner!) {
        if self.delegate != nil {
            self.taskRunner = self.delegate!.taskRunnerMangerWillFreezeTask(self)
            
            //            NSUserDefaults.standardUserDefaults().setInteger(secondsLeft, forKey: GlobalConstants.k_SECONDS_LEFT)
            NSUserDefaults.standardUserDefaults().setValue(NSDate(), forKey: GlobalConstants.k_FROZEN_DATE)
        }
    }
    
    func activeFrozenTaskManager() {
        
        if self.delegate != nil && self.taskRunner != nil{
            let frozenDate = NSUserDefaults.standardUserDefaults().valueForKey(GlobalConstants.k_FROZEN_DATE) as NSDate
            let elapsedSeconds = Int(NSDate().timeIntervalSinceDate(frozenDate))
            if elapsedSeconds >= self.taskRunner!.seconds {
            self.taskRunner!.seconds = 1
            } else {
                self.taskRunner!.seconds -= elapsedSeconds
            }
            self.delegate!.taskRunnerManger(self, didActiveFrozenTaskRunner: self.taskRunner)
        }
    }
}
