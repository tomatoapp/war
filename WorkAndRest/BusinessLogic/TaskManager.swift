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
    
    let mmwornhole = MMWormhole(applicationGroupIdentifier: IdentifierDef.AppGroupIdentifier, optionalDirectory: nil)

    
    class var sharedInstance: TaskManager {
        return _singletonInstance
    }
    
    override init() {
        super.init()
        
        self.mmwornhole.listenForMessageWithIdentifier(IdentifierDef.TestIdentifier, listener: { (message) -> Void in
            //println("Fire!!!")
            let task = Task()
            task.taskId = 1
            task.lastUpdateTime = NSDate()
            task.title = "~~ duang! ~"
            
            self.startTask(task)
        })
    }
    
    func loadTaskList() -> Array<Task> {
        
        if self.cacheTaskList.count > 0 {
            return self.cacheTaskList
        }
        
        let result = DBOperate.loadAllTasks()
        if result != nil {
            // remove the finished item
            let date = NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 7 * -1)
           let filtered = result!.filter { !$0.completed || ($0.completed && $0.lastUpdateTime.compare(date) == NSComparisonResult.OrderedDescending) }
            self.cacheTaskList = filtered
        }
        return self.cacheTaskList
    }
    
    func loadUnCompletedTaskList() -> Array<Task> {
        let tasks = self.loadTaskList()
        let unCompletedTasks = tasks.filter { $0.completed == false }
        return unCompletedTasks
    }
    
    
    func removeTask(task: Task!) -> Bool {
        
        // Remove it from the cache.
        let target = cacheTaskList.filter {$0.taskId == task.taskId }.first!
        cacheTaskList.removeAtIndex(cacheTaskList.indexOf(target)!)
        
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
        task.lastUpdateTime = NSDate()
        task.finished_times += 1
        
        // Update the cache
        let target = cacheTaskList.filter { $0.taskId == task.taskId }.first!
        target.lastUpdateTime = task.lastUpdateTime
        target.finished_times = task.finished_times
        
        print("completeOneTimer: \(target.finished_times)")
        
        // Update the database.
        let success = DBOperate.updateTask(task)
        if success {
            self.record(task, isFinished: true)
        }
        return success
    }
    
    func breakOneTimer(task: Task!) -> Bool {
        task.lastUpdateTime = NSDate()
        task.break_times += 1

        // Update the cache
        let target = cacheTaskList.filter { $0.taskId == task.taskId }.first!
        target.lastUpdateTime = task.lastUpdateTime
        target.break_times = task.break_times
        
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
        target.completedTime = NSDate()
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
    
    
    func updateTask(task: Task!) {
        
        // Update the cache.
        let target = cacheTaskList.filter { $0.taskId == task.taskId }.first!
        target.title = task.title
        
        // Update the database.
        DBOperate.updateTask(task)
    }
    
    func selectTask(taskId: Int) -> Task {
        let target = cacheTaskList.filter { $0.taskId == taskId }.first!
        return target
    }
    
    func record(task: Task, isFinished: Bool) {
        let work = Work()
        work.taskId = task.taskId
        work.isFinished = isFinished
        WorkManager.sharedInstance.insertWork(work)
    }
}
