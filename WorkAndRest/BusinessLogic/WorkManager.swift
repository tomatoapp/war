//
//  WorkManager.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/23.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

enum TimeSpanType {
    case Week, Month, Year
}

private let _singletonInstance = WorkManager()

class WorkManager: NSObject {
    
    var hasNewValue = true
    
    class var sharedInstance: WorkManager {
        return _singletonInstance
    }
    
    var cacheWorkList = [Work]()
    
    func loadWorkList() -> Array<Work> {
        
        /*
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let startDate = dateFormater.dateFromString("2016-1-4 12:12:12")!
        let endDate = dateFormater.dateFromString("2016-1-17 12:12:12")!
        let result = DBOperate.loadWorksByDate(startDate, endDate: endDate)
        print(result?.count)
        return [Work]()
        */
        
        if !self.hasNewValue && self.cacheWorkList.count > 0 {
        print("==cache works.")
        return self.cacheWorkList
        }
        print("=====db works.")
        let result = DBOperate.loadAllWorks()
        if result != nil {
        self.cacheWorkList = result!
        self.hasNewValue = false
        }
        return self.cacheWorkList
    }
    
    func selectWorksByTimeType(type: TimeSpanType) -> Array<Work> {
        let date = self.getDateTimeByTimeSpanType(type)
        let allTasks = self.loadWorkList()
        return allTasks.filter { $0.workTime.compare(date) != NSComparisonResult.OrderedAscending }
    }
    
    func getDateTimeByTimeSpanType(type: TimeSpanType) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let comps = NSDateComponents()
        switch type {
        case .Week:
            comps.day = -7
            break
            
        case .Month:
            comps.month = -1
            break
            
        case .Year:
            comps.year = -1
            break
        }
        return calendar.dateByAddingComponents(comps, toDate: NSDate(), options: NSCalendarOptions())!
    }
    
    func insertWork(work: Work) {
        DBOperate.insertWork(work)
        self.hasNewValue = true
        
    }
    func loadWorksByTask(task: Task) {
        DBOperate.loadWorksByTaskID(task.taskId)
    }
}
