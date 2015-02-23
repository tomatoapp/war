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
    
    class var sharedInstance: WorkManager {
        return _singletonInstance
    }
    
    var cacheWorkList = [Work]()
    
    func loadWorkList() -> Array<Work> {
        if self.cacheWorkList.count > 0 {
            return self.cacheWorkList
        }
        let result = DBOperate.loadAllWorks()
        if result != nil {
            self.cacheWorkList = result!
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
        return calendar.dateByAddingComponents(comps, toDate: NSDate(), options: NSCalendarOptions.allZeros)!
    }
}
