//
//  DBOperate.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/28.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

@objc class DBOperate {

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
    class func updateTask(task: Task) {
        if !dataBase.open() {
            return
        }
        let success = dataBase.executeUpdate("UPDATE t_tasks SET title = ? WHERE task_id = ?", withArgumentsInArray: [task.title, task.taskId])
        if success {
            println("update task table success.")
        } else {
            println("update task table failed!")
        }
        dataBase.close()
    }
    class func deleteTask(task: Task) {
        if !dataBase.open() {
            return
        }
        let success = dataBase.executeUpdate("DELETE FROM t_tasks WHERE task_id = ?", withArgumentsInArray: [task.taskId])
        if success {
            println("delete from task success.")
        } else {
            println("delete from task failed!")
        }
        dataBase.close()
    }
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
    class func insertWork(work: Work) {
        if !dataBase.open() {
            return
        }
        let success = dataBase.executeUpdate("INSERT INTO t_works(title) VALUES (:title)", withArgumentsInArray: [work.title])
        if success {
            println("insert to work table success.")
        } else {
            println("inert to work table failed!")
        }
        dataBase.close()
    }
    class func selectWorkWithWorkId(workId: Int) -> Work? {
        if !dataBase.open() {
            return nil
        }
        var work = Work()
        let rs = dataBase.executeQuery("SELECT * from t_works WHERE work_id = ?", withArgumentsInArray: [workId])
        while rs.next() {
            work.workId = rs.stringForColumn("task_id").toInt()!
            work.title = rs.stringForColumn("title")
        }
        dataBase.close()
        return work
    }
    class func updateWork(work: Work) {
        if !dataBase.open() {
            return
        }
        let success = dataBase.executeUpdate("UPDATE t_works SET title = ? WHERE work_id = ?", withArgumentsInArray: [work.title, work.workId])
        if success {
            println("update work table success.")
        } else {
            println("update work table failed!")
        }
        dataBase.close()
    }
    class func deleteWork(work: Work) {
        if !dataBase.open() {
            return
        }
        let success = dataBase.executeUpdate("DELETE FROM t_works WHERE work_id = ?", withArgumentsInArray: [work.workId])
        if success {
            println("delete from work table success.")
        } else {
            println("delete from work table failed!")
        }
        dataBase.close()
    }
    class func loadAllWorks() -> Array<Work>? {
        if !dataBase.open() {
            return nil
        }
        var workArray = [Work]()
        let rs = dataBase.executeQuery("SELECT * from t_works", withArgumentsInArray: nil)
        while rs.next() {
            let tempWork = Work()
            tempWork.workId = rs.stringForColumn("work_id").toInt()!
            tempWork.title = rs.stringForColumn("title")
            workArray.append(tempWork)
        }
        dataBase.close()
        return workArray
    }
}
