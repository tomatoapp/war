//
//  TaskManager.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/14.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

protocol TaskManagerDelegate {
    func taskManger(taskManager: TaskManager, didActivatedATask task: Task!)
}

private let _singletonInstance = TaskManager()

class TaskManager: NSObject {
    var delegate: TaskManagerDelegate?
    var cacheTaskList = [Task]()
    
    class var sharedInstance: TaskManager {
        return _singletonInstance
    }
    
    override init() {
        super.init()
    }
    
    func loadTaskList() -> Array<Task> {
        let result = DBOperate.loadAllTasks()
        if result != nil {
            self.cacheTaskList = result!
        }
        return self.cacheTaskList
    }
    
    func removeTask(task: Task!) -> Bool {
        
        // Remove it from the cache.
        let target = cacheTaskList.filter {$0.taskId == task.taskId }.first!
        cacheTaskList.removeAtIndex(find(cacheTaskList, target)!)
        
        // Remove it from the database.
        let success = DBOperate.deleteTask(task)
        return success
    }
    
    func addTask(task: Task!) -> Bool {
        // Add to the cache.
        cacheTaskList.insert(task, atIndex: 0)
        
        // Add to the database.
        let success = DBOperate.insertTask(task)
        return success
    }
    
    func startTask(task: Task!) -> Bool {
        task.lastUpdateTime = NSDate()

        // Update the cache.
        let target = cacheTaskList.filter { $0.taskId == task.taskId }.first!
        target.lastUpdateTime = task.lastUpdateTime
        
        // Update the database.
        let success = DBOperate.updateTask(task)
        return success
    }
    
    func completeOneTimer(task: Task!) -> Bool {
        println("completeOneTimer")
        task.lastUpdateTime = NSDate()
        task.finished_times += 1
        
        // Update the cache
        let target = cacheTaskList.filter { $0.taskId == task.taskId }.first!
        target.lastUpdateTime = task.lastUpdateTime
        target.finished_times += 1
        
        // Update the database.
        let success = DBOperate.updateTask(task)
        if success {
            self.record(task, isFinished: true)
        }
        return success
    }
    
    func breakOneTimer(task: Task!) -> Bool {
        println("breakOneTimer")
        task.lastUpdateTime = NSDate()
        
        // Update the cache
        let target = cacheTaskList.filter { $0.taskId == task.taskId }.first!
        target.lastUpdateTime = task.lastUpdateTime
        target.break_times += 1
        // Update the database.
        let success = DBOperate.updateTask(task)
        if success {
            self.record(task, isFinished: false)
        }
        return success
    }
    
    func markDoneTask(task: Task!) {
        task.completed = true
        
        // Update the cache.
        let target = cacheTaskList.filter { $0.taskId == task.taskId }.first!
        target.completed = true
        // Update the database.
        
        // Update the database.
        DBOperate.updateTask(task)
    }
    
    func activeTask(task: Task!) {
        task.completed = false
        
        // Update the cache.
        let target = cacheTaskList.filter { $0.taskId == task.taskId }.first!
        target.completed = false
        
        // Update the database.
        DBOperate.updateTask(task)
        
        // Notification.
        self.delegate?.taskManger(self, didActivatedATask: task)
    }
    
    func record(task: Task, isFinished: Bool) {
        let work = Work()
        work.taskId = task.taskId
        work.isFinished = isFinished
        DBOperate.insertWork(work)
    }
}
