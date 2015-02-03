//
//  TaskManager.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/4.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

protocol TaskManagerDelegate {
    func taskMangerWillFreezeTask(taskManager: TaskManager!) -> Task
    func taskManger(taskManager: TaskManager!, didActiveFrozenTask task:Task)
}

class TaskManager: NSObject {
    var delegate:TaskManagerDelegate?
    
    func freezeTask(task: Task!) {
        if self.delegate != nil {
            let task = self.delegate!.taskMangerWillFreezeTask(self)
        }
    }
    
    func activeFrozenTask() {
        let task = Task()
        if self.delegate != nil {
            self.delegate!.taskManger(self, didActiveFrozenTask: task)
        }
    }
}
