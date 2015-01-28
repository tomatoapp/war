//
//  DBOperate.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/28.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

@objc class DBOperate {
    
//    private var once = dispatch_once_t()
//    var dataBase: FMDatabase = FMDatabase()

//    init() {
//        dispatch_once(&once) {
//            let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
//            let path = documentsFolder.stringByAppendingString("db_demo.sqlite3")
//            //self.dataBase = FMDatabase(path: path)
//            self.dataBase = FMDatabase(path: path)
//        }
//    }

    
    struct Static {
        static var db = FMDatabase()
    }
    
    class var dataBase: FMDatabase {
        get { return Static.db }
        set { Static.db = newValue }
    }
    
    class func db_init() {
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let path = documentsFolder.stringByAppendingString("db_demo.sqlite3")
        DBOperate.dataBase = FMDatabase(path: path)
    }
    
    // MARK: - Task
    class func createTaskTable() {
        
    }
    
    class func insertTask(task: Task) {
        
    }
    
    class func selectTaskWithTaskId(taskId: Int) -> Task {
        var task = Task()
        return task
    }
    class func updateTask(task: Task) {}
    class func deleteTask(task: Task) {}
    class func loadAllTasks() -> Array<Task> {
        var taskArray = [Task]()
        return taskArray
    }
    
    // MARK: - Work
    class func createWorkTable() {}
    class func insertWork(work: Work) {}
    class func selectWorkWithWorkId(taskId: Int) -> Work {
        var work = Work()
        return work
    }
    class func updateWork(work: Work) {}
    class func deleteWork(work: Work) {}
    class func loadAllWorks() -> Array<Work> {
        var workArray = [Work]()
        return workArray
    }
}
