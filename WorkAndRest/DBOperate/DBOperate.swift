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
        let path = documentsFolder.stringByAppendingPathComponent("db_demo.sqlite3")
        dataBase = FMDatabase(path: path)

        let fileManager = NSFileManager.defaultManager()
        if (!fileManager.fileExistsAtPath(path)) {
            self.createTaskTable()
            self.createWorkTable()
        }
    }
    
    // MARK: - Task
    class func createTaskTable() {
        let sql = "CREATE TABLE t_tasks(task_id integer primary key autoincrement, title VARCHAR(1024))"
        if !dataBase.open() {
            println("Unable to open the db.")
            return
        }
        let success = dataBase.executeUpdate(sql, withArgumentsInArray: nil)
        if success {
            println("Create the task table success.")
        }
        dataBase.close()
    }
    
    class func insertTask(task: Task) {
        // open the db
        if !dataBase.open() {
            return
        }
        let success = dataBase.executeUpdate("INSERT INTO t_tasks(title) VALUES (:title)", withArgumentsInArray: [task.title])
        if success {
            println("insert to task table success.")
        } else {
            println("insert to task table failed!")
        }
        dataBase.close()
    }
    
    class func selectTaskWithTaskId(taskId: Int) -> Task? {
        if !dataBase.open() {
            return nil
        }
        let task = Task()
        let rs = dataBase.executeQuery("SELECT * from t_tasks WHERE task_id = (?)", withArgumentsInArray: [taskId])
        while rs.next() {
            task.taskId = rs.stringForColumn("task_id").toInt()!
            task.title = rs.stringForColumn("title")
        }
        return task
    }
    class func updateTask(task: Task) {}
    class func deleteTask(task: Task) {}
    
    class func loadAllTasks() -> Array<Task>? {
        if !dataBase.open() {
            return nil
        }
        var taskArray = [Task]()
        let rs = dataBase.executeQuery("SELECT * from t_tasks", withArgumentsInArray: nil)
        while rs.next() {
            let tempTask = Task()
            tempTask.taskId = rs.stringForColumn("task_id").toInt()!
            tempTask.title = rs.stringForColumn("title")
            taskArray.append(tempTask)
        }
        dataBase.close()
        return taskArray
    }
    
    // MARK: - Work
    class func createWorkTable() {
        let sql = "CREATE TABLE t_works(work_id DECIMAL(18,0) DEFAULT '0', title VARCHAR(1024))"
        if !dataBase.open() {
            println("Unable to open the db.")
            return
        }
        let success = dataBase.executeUpdate(sql, withArgumentsInArray: nil)
        if success {
            println("Create the work table success.")
        }
        dataBase.close()
    }
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
