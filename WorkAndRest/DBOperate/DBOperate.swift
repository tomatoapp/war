//
//  DBOperate.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/28.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

class DBOperate {

    struct Static {
        static var db = FMDatabase()
    }
    
    class var dataBase: FMDatabase {
        get { return Static.db }
        set { Static.db = newValue }
    }
    
    class func db_init() {
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        let path = documentsFolder.stringByAppendingString("/db_demo.sqlite3")
        dataBase = FMDatabase(path: path)

//        let fileManager = NSFileManager.defaultManager()
//        if (!fileManager.fileExistsAtPath(path)) {
//            self.createTaskTable()
//            self.createWorkTable()
//        }
        
        self.createTaskTable()
        self.createWorkTable()
    }
    
    // MARK: - Task
    class func createTaskTable() {
        let sql = "CREATE TABLE IF NOT EXISTS t_tasks(" +
            "task_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT DEFAULT 1," +
            "title VARCHAR(1024) NOT NULL," +
            "lastUpdateTime DATETIME DEFAULT CURRENT_TIMESTAMP," +
            "minutes INTEGER, " +
            "expect_times INTERGER, " +
            "finished_times INTERGER, " +
            "break_times INTERGER, " +
            "completedTime DATETIME, " +
            "completed BOOL DEFAULT 0" +
        ")"
        
        if !dataBase.open() {
            print("Unable to open the db.")
            return
        }
        let success = dataBase.executeUpdate(sql, withArgumentsInArray: nil)
        if success {
//            println("Create the task table success.")
        }
        dataBase.close()
    }
    class func insertTask(task: Task) -> Bool {
        // open the db
        if !dataBase.open() {
            return false
        }
        let success = dataBase.executeUpdate("INSERT INTO t_tasks(title, minutes, completed, expect_times, finished_times, break_times, completedTime) VALUES (:title, :minutes, :completed, :expect_times, :finished_times, :break_times, :completedTime)", withArgumentsInArray: [task.title, task.minutes, task.completed, task.expect_times, task.finished_times, task.break_times, task.completedTime])
        if success {
//            println("insert to task table success.")
        } else {
//            println("insert to task table failed!")
        }
        let lastRowId = Int(dataBase.lastInsertRowId())
        print("lastRowId: \(lastRowId)")
        task.taskId = lastRowId
        dataBase.close()
        return success
    }
    class func selectTaskWithTaskId(taskId: Int) -> Task? {
        if !dataBase.open() {
            return nil
        }
        let task = Task()
        let rs = dataBase.executeQuery("SELECT * from t_tasks WHERE task_id = (?)", withArgumentsInArray: [taskId])
        while rs.next() {
            task.taskId = Int(rs.stringForColumn("task_id"))!
            task.title = rs.stringForColumn("title")
            task.lastUpdateTime = rs.dateForColumn("lastUpdateTime")
            task.minutes = Int(rs.stringForColumn("minutes"))!
            task.expect_times = Int(rs.stringForColumn("expect_times"))!
            task.finished_times = Int(rs.stringForColumn("finished_times"))!

        }
        dataBase.close()
        return task
    }
    
    class func lastInsertId() -> Int {
        if !dataBase.open() {
            return -1
        }
        let lastRowId = Int(dataBase.lastInsertRowId())
        dataBase.close()
        print("lastRowId: \(lastRowId)")
        return lastRowId
    }
    
    class func updateTask(task: Task) -> Bool {
        if !dataBase.open() {
            return false
        }
        
        // also can use datetime('now'):
        // lastUpdateTime = ? -> lastUpdateTime = datetime('now')
        let success = dataBase.executeUpdate("UPDATE t_tasks SET title = ?, lastUpdateTime = ?, minutes = ?, completed = ?, finished_times = ?, break_times = ?, completedTime = ? WHERE task_id = ?", withArgumentsInArray: [task.title, task.lastUpdateTime, task.minutes, task.completed, task.finished_times, task.break_times, task.completedTime, task.taskId])
        if success {
            print("update task table success.")
        } else {
//            println("update task table failed!")
        }
        dataBase.close()
        return success
    }
    class func deleteTask(task: Task) -> Bool {
        if !dataBase.open() {
            return false
        }
        let success = dataBase.executeUpdate("DELETE FROM t_tasks WHERE task_id = ?", withArgumentsInArray: [task.taskId])
        if success {
//            println("delete from task success.")
        } else {
//            println("delete from task failed!")
        }
        dataBase.close()
        return success
    }
    class func loadAllTasks() -> Array<Task>? {
        if !dataBase.open() {
            return nil
        }
        var taskArray = [Task]()
        let rs = dataBase.executeQuery("SELECT * from t_tasks", withArgumentsInArray: nil)
        while rs.next() {
            let tempTask = Task()
            tempTask.taskId = Int(rs.stringForColumn("task_id"))!
            tempTask.title = rs.stringForColumn("title")
            tempTask.minutes = Int(rs.stringForColumn("minutes"))!
            tempTask.lastUpdateTime = rs.dateForColumn("lastUpdateTime")
            tempTask.completed = rs.boolForColumn("completed")
            if tempTask.lastUpdateTime.description.hasPrefix("1970") {
                let formatter = NSDateFormatter()
                let GMTzone = NSTimeZone(forSecondsFromGMT: 0)
                formatter.timeZone = GMTzone
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                tempTask.lastUpdateTime = formatter.dateFromString(rs.stringForColumn("lastUpdateTime"))!
            }
            tempTask.expect_times = Int(rs.stringForColumn("expect_times"))!
            tempTask.finished_times = Int(rs.stringForColumn("finished_times"))!
            tempTask.break_times = Int(rs.stringForColumn("break_times"))!
            tempTask.completedTime = rs.dateForColumn("completedTime")

            taskArray.append(tempTask)
        }
        dataBase.close()
//        println("load task list count: \(taskArray.count)")
        return taskArray
    }
    
    // MARK: - Work
    class func createWorkTable() {
        let sql = "CREATE TABLE IF NOT EXISTS t_works(" +
        "work_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT DEFAULT 1," +
        "task_id INTEGER NOT NULL DEFAULT 1," +
        "work_time DATETIME DEFAULT CURRENT_TIMESTAMP," +
        "is_finished BOOL DEFAULT 0" +
        ")"
        if !dataBase.open() {
            print("Unable to open the db.")
            return
        }
        let success = dataBase.executeUpdate(sql, withArgumentsInArray: nil)
        if success {
//            println("Create the work table success.")
        }
        dataBase.close()
    }
    class func insertWork(work: Work) {
        if !dataBase.open() {
            return
        }
        let success = dataBase.executeUpdate("INSERT INTO t_works(task_id, is_finished, work_time) VALUES (:task_id, :is_finished, :work_time)", withArgumentsInArray: [work.taskId, work.isFinished, work.workTime])
        if success {
//            println("insert to work table success.")
        } else {
//            println("inert to work table failed!")
        }
        dataBase.close()
    }
    class func selectWorkWithWorkId(workId: Int) -> Work? {
        if !dataBase.open() {
            return nil
        }
        let work = Work()
        let rs = dataBase.executeQuery("SELECT * from t_works WHERE work_id = ?", withArgumentsInArray: [workId])
        while rs.next() {
            work.workId = Int(rs.stringForColumn("work_id"))!
            work.taskId = Int(rs.stringForColumn("task_id"))!
        }
        dataBase.close()
        return work
    }
    
    class func SelectWorkListWithTaskId(taskId: Int) -> Array<Work>? {
        if !dataBase.open() {
            return nil
        }
        var workArray = [Work]()
        let rs = dataBase.executeQuery("SELECT * from t_works WHERE task_id = ?", withArgumentsInArray: [taskId])
        while rs.next() {
            let workTemp = Work()
            workTemp.workId = Int(rs.stringForColumn("work_id"))!
            workTemp.taskId = Int(rs.stringForColumn("task_id"))!
            workTemp.workTime = rs.dateForColumn("work_time")
            workTemp.isFinished = rs.boolForColumn("is_finished")
            workArray.append(workTemp)
        }
        dataBase.close()
//        println("load work list count: \(workArray.count)")
        return workArray
    }

    class func loadAllWorks() -> Array<Work>? {
        if !dataBase.open() {
            return nil
        }
        var workArray = [Work]()
        let rs = dataBase.executeQuery("SELECT * from t_works", withArgumentsInArray: nil)
        while rs.next() {
            let tempWork = Work()
            tempWork.workId = Int(rs.stringForColumn("work_id"))!
            tempWork.taskId = Int(rs.stringForColumn("task_id"))!
            tempWork.workTime = rs.dateForColumn("work_time")
            if tempWork.workTime.description.hasPrefix("1970") {
                let formatter = NSDateFormatter()
                let GMTzone = NSTimeZone(forSecondsFromGMT: 0)
                formatter.timeZone = GMTzone
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                tempWork.workTime = formatter.dateFromString(rs.stringForColumn("work_time"))!
            }
            tempWork.isFinished = rs.boolForColumn("is_finished")
            workArray.append(tempWork)
        }
        dataBase.close()
        return workArray
    }
}
