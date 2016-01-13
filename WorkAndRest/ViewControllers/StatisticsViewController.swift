//
//  StatisticsViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/20.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

class StatisticsViewController: BaseTableViewController, JBBarChartViewDelegate, JBBarChartViewDataSource, StatisticsLockerDelegate, ProductsManagerDelegate {
    
    //@IBOutlet var showPercentageSwitch: UISwitch!
    @IBOutlet var statisticsView: UIView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var commentsView: UIView!
    @IBOutlet var statisticsBg: UIImageView!
    
    var chatType =  TimeSpanType.Month
    var chartView: JBBarChartView!
    var chartViewFooterView: UIView!
    var chartViewHeaderView: UIView!
    var data = [CGFloat]()
    var baseData: [Int: Array<Work>] = [:]
    var currentIndex = -1
    var tooltipVisible = false
//    var isShowPercentageSwitchOn = true
    
    var tooltip: UILabel!
    var locker: StatisticsLocker?
    
    var maximumHeight: CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var frame: CGRect!
        
        switch WARDevice.getPhoneType() {
        case .iPhone4, .iPhone5:
            frame = CGRectMake(0, 0, 270-50, 157) // 270
            break
            
        case .iPhone6, .iPhone6Plus:
            frame = CGRectMake(0, 0, 360-50, 157) // 360
            break
            
        default:
            break
        }
        self.chartView = JBBarChartView(frame: frame)
        self.statisticsView.addSubview(self.chartView)
        
        self.chartView.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.statisticsView.mas_centerX)
            make.centerY.equalTo()(self.statisticsView.mas_centerY).offset()(-17)
            make.width.equalTo()(frame.size.width)
            make.height.equalTo()(frame.size.height)
            return ()
        }
        
        self.chartView.delegate = self
        self.chartView.dataSource = self
        self.chartView.minimumValue = 0.0
        
        ProductsManager.sharedInstance.delegate = self
    }
    
    func setStateToExpanded() {
        self.chartView.reloadData()
        self.chartView.setState(.Expanded, animated: true)
        self.setChartViewHeaderViewVisible(true, withAmination: true)
    }
    
    func setStateToCollapsed() {
        self.chartView.setState(.Collapsed, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.needLockTheChart() {
            self.lockTheChart()
        } else {
            self.locker?.removeFromSuperview()
        }
        self.loaDataSourceBySegmentedControlSelectedIndex(self.segmentedControl.selectedSegmentIndex)
        self.chartView.reloadData()
        
        /*
        if !NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kBOOL_hasShownChartTutorial) {
            self.showTurorial()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kBOOL_hasShownChartTutorial)
        }
        */
    }
    
    /*
    func showTurorial() {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("showChartTutorialSegue", sender: nil)
            return
        })
        
    }
    */
    
    func lockTheChart() {
//        let locker = UIImageView(image: UIImage(named: "lock chart"))
//        locker.frame = CGRectMake(0, 0, self.view.frame.size.width - 26, 193)
        
        self.locker = StatisticsLocker(frame: CGRectMake(0, 0, self.view.frame.size.width - 25, 193))
        locker!.delegate = self
        self.statisticsView.addSubview(locker!)
        self.statisticsView.bringSubviewToFront(locker!)
    }
    
    func needLockTheChart() -> Bool {
        return false;
    }
    
    @IBAction func segmentControlValueChanged(sender: AnyObject) {
        self.loaDataSourceBySegmentedControlSelectedIndex((sender as! UISegmentedControl).selectedSegmentIndex)
    }
    
    // MARK: - Methods
    
    func loaDataSourceBySegmentedControlSelectedIndex(index: Int) {
        var type: TimeSpanType = .Week
        switch index {
        case 0:
            // Week
            type = .Week
            break
            
        case 1:
            // Month
            type = .Month
            break
            
        case 2:
            // Year
            type = .Year
            break
            
        default:
            break
        }
        self.chatType = type
        self.loadDataSourceByType(type)
        
        self.removeFooterViewFromTheStatisticsView()
        self.addFooterViewToTheStatisticsView(type)
        
        self.removeHeaderViewFromTheStatisticsView()
        //self.addHeaderViewToTheStatisticsView()
    }
    
    func setChartViewHeaderViewVisible(visible: Bool, withAmination animation: Bool) {
        if self.chartViewHeaderView == nil {
            return
        }
        
        let setVisible: () -> Void = {
            self.chartViewHeaderView.alpha = visible ? 1.0 : 0.0
        }
        
        if animation {
            UIView.animateWithDuration(0.3,
                animations: { () -> Void in
                    setVisible()
                }, completion: nil)
        } else {
            setVisible()
        }
    }
    /*
    func setCommentsViewVisible(visible: Bool) {
        UIView.animateWithDuration(0.3,
            animations: { () -> Void in
                self.commentsView.alpha = visible ? 1.0 : 0.0
            }, completion: nil)
    }
    */
    
    func loadDataSourceByType(type: TimeSpanType) {
        
        let allTasks = WorkManager.sharedInstance.selectWorksByTimeType(type)
        self.data.removeAll(keepCapacity: false)
        
        let dic = self.getWorksCountWithGroup(allTasks, byType: type)
        self.baseData = dic
        for index in 0...dic.count-1 {
            let works = dic[index]! as Array<Work>
            //            if works.count == 0 {
            //                continue
            //            }
            var finishedCount = 0
            var stopedCount = 0
            for work in works {
                if work.isFinished {
                    finishedCount++
                } else {
                    stopedCount++
                }
            }
            self.data.insert(CGFloat(finishedCount), atIndex: 0)
            //self.data.insert(CGFloat(stopedCount), atIndex: 1)
        }
        /*
        // 1. Remove the zero item from the top of the data source.
        while self.data.count >= 2 && (self.data[0] == 0 && self.data[1] == 0) {
            self.data.removeAtIndex(0)
            //self.data.removeAtIndex(0)
        }
        
        while self.data.count < self.getNumberOfBarsByPhoneSize() {
            self.data.append(CGFloat(0))
        }
        */
        self.setChatViewMaximumValue(self.data.maxElement()!)
        self.setStateToCollapsed()

        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("setStateToExpanded"), userInfo: nil, repeats: false)
    }
    
    func getCapacity() -> Int {
        /*
        if WARDevice.getPhoneType() == .iPhone6 || WARDevice.getPhoneType() == .iPhone6Plus {
            return 4
        }
        return 3
        */
        switch self.chatType {
            case .Week:
                return 7
            
            case .Month:
                return 4*2
            
            case .Year:
                return 12
        }
    }
    
    func setChatViewMaximumValue(value: CGFloat) {
        if value > 20 {
            // 20 = 30 / 1.4858
            // If the value too large, then set the max height of the chat to the_max_number * 1.4858
             self.maximumHeight = value * 1.4858
        } else {
            self.maximumHeight = 30
        }
    self.chartView.maximumValue = self.maximumHeight
    }
    
    func getWorksCountWithGroup(list: Array<Work>, byType type: TimeSpanType) -> [Int: Array<Work>]{
        
        var dic = [Int: Array<Work>]()
        
        let startComponents = NSCalendar.currentCalendar().components([.Year, .Month, .WeekOfMonth, .Weekday, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second] , fromDate: NSDate())
        
        let endComponents = NSCalendar.currentCalendar().components([.Year, .Month, .WeekOfMonth, .Weekday, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second] , fromDate: NSDate())
        
        startComponents.hour = 0
        startComponents.minute = 0
        startComponents.second = 1
        endComponents.hour = 23
        endComponents.minute = 59
        startComponents.second = 59
        
        let capacity = self.getCapacity()
        
        switch type {
        case .Week:
            for i in 0...capacity-1 {
                startComponents.day = startComponents.day - (i == 0 ? 0 : 1)
                endComponents.day = startComponents.day
                let startDate = NSCalendar.currentCalendar().dateFromComponents(startComponents)!
                let endDate = NSCalendar.currentCalendar().dateFromComponents(endComponents)!
                let result = self.filterWorks(list, byStartDate: startDate, andEndDate: endDate)
                dic[i] = result
            }
            break
            
        case .Month:
            startComponents.day = startComponents.day - startComponents.weekday + 1
            for i in 0...capacity-1 {
                startComponents.day = startComponents.day - ((i == 0 ? 0 : 1) * 7)
                endComponents.day = startComponents.day + 6
                let startDate = NSCalendar.currentCalendar().dateFromComponents(startComponents)!
                let endDate = NSCalendar.currentCalendar().dateFromComponents(endComponents)!
                print("\(startDate) ~ \(endDate)  \(i)")
                let result = self.filterWorks(list, byStartDate: startDate, andEndDate: endDate)
                dic[i] = result
            }
            break
            
        case .Year:
            startComponents.day = 1
            endComponents.day = 0
            for i in 0...capacity-1 {
                startComponents.month = startComponents.month - (i == 0 ? 0 : 1)
                endComponents.month = startComponents.month + 1
                let startDate = NSCalendar.currentCalendar().dateFromComponents(startComponents)!
                let endDate = NSCalendar.currentCalendar().dateFromComponents(endComponents)!
                let result = self.filterWorks(list, byStartDate: startDate, andEndDate: endDate)
                dic[i] = result
            }
            break
        }
        return dic
    }
    
    func filterWorks(list: Array<Work>, byStartDate startDate: NSDate, andEndDate endDate: NSDate) -> Array<Work> {
        return list.filter { $0.workTime.compare(startDate) != NSComparisonResult.OrderedAscending && $0.workTime.compare(endDate) != NSComparisonResult.OrderedDescending }
    }
    
    func removeFooterViewFromTheStatisticsView() {
        if self.chartViewFooterView != nil && self.chartViewFooterView.superview != nil {
            self.chartViewFooterView.removeFromSuperview()
        }
    }

    func removeHeaderViewFromTheStatisticsView() {
        if self.chartViewHeaderView != nil && self.chartViewHeaderView.superview != nil {
            self.chartViewHeaderView.removeFromSuperview()
        }
    }

    
    func addFooterViewToTheStatisticsView(type: TimeSpanType) {
        let LABEL_HEIGHT: CGFloat = 25
        self.chartViewFooterView = UIView(frame: CGRectMake(0, 0, self.chartView.frame.width + 50, LABEL_HEIGHT))
        
        let todayComponents = self.getComponentsByDate(NSDate())
        var names = [String]()

        var dates = [NSDate?]()
        for index in 0...self.baseData.count-1 {
            let works = self.baseData[index]! as Array<Work>
            dates.insert(works.first?.workTime, atIndex: 0)
        }
        
        while dates.count > 0 && dates[0] == nil {
            dates.removeAtIndex(0)
        }
        
        while dates.count < self.getCapacity()  {
            dates.append(nil)
        }
        print("dates: \(dates)")
        
        // If the dates[0] is nil, mean that all the list is nil.
        
        if dates[0] == nil {
            dates[0] = NSDate()
        }
//        currentIndex = -1
        switch type {
        case .Week:
            /*
            currentIndex = self.daysBetweenDateFromDate(dates[0]!, toDate: NSDate())
            print("todayIndex: \(currentIndex)")
            // Covert the number to Week day string.
            weekDayNames.append(self.self.getWeekDayStringByWeekDayNumber(todayComponents.weekday))
            // if todayIndex is zero, mean that today is the first day.
            // if todayIndex is not zero, mean that today is not the first day. maybe in the middle, and maybe in the end.
            if currentIndex > 0 {
                var tempComponents: NSDateComponents = NSDateComponents()
                for index in 0...currentIndex-1 {
                    let tempDate = dates[index]
                    if tempDate != nil {
                        tempComponents = self.getComponentsByDate(tempDate)
                    } else {
                        tempComponents.weekday += 1
                    }
                    weekDayNames.insert(self.self.getWeekDayStringByWeekDayNumber(tempComponents.weekday), atIndex: weekDayNames.count-1)
                }
            }
            */
            for i in 0...((self.getCapacity() - 1) * 1) {
                let day = NSDate().addDays(-i)
                
                if i == (self.getCapacity() - 1) {
                    names.insert(day.toString(), atIndex: 0)
                } else {
                    names.insert(day.toSampleString(), atIndex: 0)
                }
            }
            break
            
        case .Month:
            // Get the first day of the week, and add them into a new list.
            var firstDayOfTheWeekDates = [NSDate?]()
            for date in dates {
                if date == nil {
                    firstDayOfTheWeekDates.append(nil)
                    continue
                }
                let components = self.getComponentsByDate(date)
                components.day = components.day - components.weekday + 1
                firstDayOfTheWeekDates.append(NSCalendar.currentCalendar().dateFromComponents(components))
            }
            print("dates: \(firstDayOfTheWeekDates) (firstDayOfTheWeekDates)")
            
            currentIndex = abs(self.weeksBetweenDateFromDate(firstDayOfTheWeekDates[0]!, toDate: NSDate()))
            print("todayIndex: \(currentIndex)")
            
            // Covert the number to Week day string.
            let components = self.getComponentsByDate(NSDate())
            components.day = components.day - components.weekday + 1
            
            names.append(self.getWeekStringByDate(NSCalendar.currentCalendar().dateFromComponents(components)))
            var preUnNilDate: NSDate!
            if currentIndex > 0 {
                for index in 0...currentIndex-1 {
                    let tempDate = firstDayOfTheWeekDates[index]
                    if tempDate != nil {
                        preUnNilDate = tempDate
                        names.insert(self.getWeekStringByDate(tempDate), atIndex: names.count-1)
                    } else {
                        // If the tempDate is nil, this mean that the firstDayOfTheWeekDates has empty item.
                        let preTempDateComponents = self.getComponentsByDate(preUnNilDate)
                        preTempDateComponents.day += 7 // Move to next week.
                        let lastWeek = NSCalendar.currentCalendar().dateFromComponents(preTempDateComponents)
                        let lastWeekComponents = self.getComponentsByDate(lastWeek)
                        lastWeekComponents.day = lastWeekComponents.day - lastWeekComponents.weekday + 1
                        let theFirstDayOfLaskWeek = NSCalendar.currentCalendar().dateFromComponents(lastWeekComponents)
                        names.insert(self.getWeekStringByDate(theFirstDayOfLaskWeek), atIndex: names.count-1)
                    }
                }
            }
            break
            
        case .Year:
            
            currentIndex = abs(self.monthsBetweenDateFromDate(dates[0]!, toDate: NSDate()))
            print("todayIndex: \(currentIndex)")

            // Covert the number to Week day string.
            names.append(self.getMonthStringByMonthNumber(todayComponents.month))

            if currentIndex > 0 {
                var tempDateComponents: NSDateComponents = NSDateComponents()
                for index in 0...currentIndex-1 {
                    let tempDate = dates[index]
                    if tempDate != nil {
                         tempDateComponents = self.getComponentsByDate(tempDate!)
                    } else {
                        tempDateComponents.month -= 1
                    }
                    names.insert(self.getMonthStringByMonthNumber(tempDateComponents.month), atIndex: names.count-1)
                }
            }
            break
        }
        print("weekDayNames - labels: \(names)")
        for index in 0...names.count - 1 {
            let tempLabel = UILabel()
            tempLabel.text = names[index]
            let capacity = self.getCapacity()
            let itemWidth: CGFloat = chartViewFooterView.frame.width / CGFloat(capacity)
            tempLabel.frame = CGRectMake(itemWidth * CGFloat(index), 0, itemWidth, LABEL_HEIGHT)
            if index == currentIndex {
                tempLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
            } else {
                tempLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
            }
            tempLabel.font = UIFont.systemFontOfSize(12)
            tempLabel.textAlignment = NSTextAlignment.Center
            chartViewFooterView.addSubview(tempLabel)
        }
//        self.statisticsView.addSubview(chartViewFooterView)
        self.statisticsView.insertSubview(chartViewFooterView, belowSubview: self.chartView)
        chartViewFooterView.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.statisticsView.mas_centerX)
            make.bottom.equalTo()(self.statisticsView.mas_bottom).offset()(-10)
            make.width.equalTo()(self.chartView.frame.width+50)
            make.height.equalTo()(LABEL_HEIGHT)
            return ()
        }
    }
    
    func getWeekDayStringByWeekDayNumber(weekDay: Int) -> String {
        switch weekDay {
            
        case 1:
//            return "Sun"
            return NSLocalizedString("Sun", comment: "")
            
        case 2:
//            return "Mon"
            return NSLocalizedString("Mon", comment: "")
            
        case 3:
//            return "Tue"
            return NSLocalizedString("Tue", comment: "")
            
        case 4:
//            return "Wed"
            return NSLocalizedString("Wed", comment: "")
            
        case 5:
//            return "Thu"
            return NSLocalizedString("Thu", comment: "")
            
        case 6:
//            return "Fri"
            return NSLocalizedString("Fri", comment: "")
            
        case 7:
//            return "Sat"
            return NSLocalizedString("Sat", comment: "")
            
        default:
            if weekDay > 7 {
                return self.getWeekDayStringByWeekDayNumber(weekDay - 7)
            } else {
                return self.getWeekDayStringByWeekDayNumber(weekDay + 7)
            }
        }
    }
    
    func getMonthStringByMonthNumber(month: Int) -> String {
        switch month {
            
        case 1:
//            return "Jan"
            return NSLocalizedString("Jan", comment: "")
            
        case 2:
//            return "Feb"
            return NSLocalizedString("Feb", comment: "")
            
        case 3:
//            return "Mar"
            return NSLocalizedString("Mar", comment: "")
            
        case 4:
//            return "Apr"
            return NSLocalizedString("Apr", comment: "")
            
        case 5:
//            return "May"
            return NSLocalizedString("May", comment: "")
            
        case 6:
//            return "Jun"
            return NSLocalizedString("Jun", comment: "")
            
        case 7:
//            return "Jul"
            return NSLocalizedString("Jul", comment: "")
            
        case 8:
//            return "Aug"
            return NSLocalizedString("Aug", comment: "")
            
        case 9:
//            return "Sept"
            return NSLocalizedString("Sept", comment: "")
            
        case 10:
//            return "Oct"
            return NSLocalizedString("Oct", comment: "")
            
        case 11:
//            return "Nov"
            return NSLocalizedString("Nov", comment: "")
            
        case 12:
//            return "Dec"
            return NSLocalizedString("Dec", comment: "")
            
        default:
            if month > 12 {
                return self.getMonthStringByMonthNumber(month - 12)
            } else {
                return self.getMonthStringByMonthNumber(month + 12)
            }
        }
    }
    
    func getWeekStringByDate(date: NSDate!) -> String {
        let startComponents = self.getComponentsByDate(date)
        let startMonthStr = self.getMonthStringByMonthNumber(startComponents.month)
        
        let copy: NSDateComponents = startComponents.copy() as! NSDateComponents
        copy.day += 6
        let endDate = NSCalendar.currentCalendar().dateFromComponents(copy)
        let endDateComponents = self.getComponentsByDate(endDate)
        let endMonthStr = self.getMonthStringByMonthNumber(endDateComponents.month)
        
        if startMonthStr == endMonthStr {
            return "\(startMonthStr) \(startComponents.day)-\(endDateComponents.day)"
        } else {
            return "\(startMonthStr) \(startComponents.day)-\(endMonthStr) \(endDateComponents.day)"
        }
    }
    
    func addPercentageLabelToTheChartView() {
        
    }
    
    func isSameDay(components1: NSDateComponents!, components2: NSDateComponents!) -> Bool {
        return components1.year == components2.year && components1.month == components2.month && components1.day == components2.day
    }
    
    func isSameDay(date1: NSDate!, date2: NSDate!) -> Bool {
        return self.isSameDay(self.getComponentsByDate(date1), components2: self.getComponentsByDate(date2))
    }
    
    func getComponentsByDate(date: NSDate!) -> NSDateComponents! {
        return NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Weekday, .WeekOfMonth, .WeekdayOrdinal, .WeekOfYear, .Hour, .Minute, .Second], fromDate: date)
    }
    
    func daysBetweenDateFromDate(date1: NSDate, toDate date2: NSDate) -> Int {
        var fromDate: NSDate?
        var toDate: NSDate?
        var duration: NSTimeInterval = 0
        
        let calendar = NSCalendar.currentCalendar()
        
        calendar.rangeOfUnit(NSCalendarUnit.NSDayCalendarUnit, startDate: &fromDate, interval: &duration, forDate: date1)
        calendar.rangeOfUnit(NSCalendarUnit.NSDayCalendarUnit, startDate: &toDate, interval: &duration, forDate: date2)
        
        let difference = calendar.components(NSCalendarUnit.NSDayCalendarUnit, fromDate: fromDate!, toDate: toDate!, options: [])
        return difference.day
    }

    func weeksBetweenDateFromDate(date1: NSDate, toDate date2: NSDate) -> Int {
        var fromDate: NSDate?
        var toDate: NSDate?
        var duration: NSTimeInterval = 0
        
        let calendar = NSCalendar.currentCalendar()
        
        calendar.rangeOfUnit(NSCalendarUnit.NSWeekOfYearCalendarUnit, startDate: &fromDate, interval: &duration, forDate: date1)
        calendar.rangeOfUnit(NSCalendarUnit.NSWeekOfYearCalendarUnit, startDate: &toDate, interval: &duration, forDate: date2)
        
        let difference = calendar.components(NSCalendarUnit.NSWeekOfYearCalendarUnit, fromDate: fromDate!, toDate: toDate!, options: [])
        return difference.weekOfYear
    }
    
    func monthsBetweenDateFromDate(date1: NSDate, toDate date2: NSDate) -> Int {
        var fromDate: NSDate?
        var toDate: NSDate?
        var duration: NSTimeInterval = 0
        
        let calendar = NSCalendar.currentCalendar()
        
        calendar.rangeOfUnit(NSCalendarUnit.NSMonthCalendarUnit, startDate: &fromDate, interval: &duration, forDate: date1)
        calendar.rangeOfUnit(NSCalendarUnit.NSMonthCalendarUnit, startDate: &toDate, interval: &duration, forDate: date2)
        
        let difference = calendar.components(NSCalendarUnit.NSMonthCalendarUnit, fromDate: fromDate!, toDate: toDate!, options: [])
        return difference.month
    }
    /*
    func addHeaderViewToTheStatisticsView() {
        let VIEW_HEIGHT: CGFloat = 157
        let LABEL_HEIGHT: CGFloat = 25
        
        self.chartViewHeaderView = UIView(frame: CGRectMake(0, 0, self.chartView.frame.width + 50, VIEW_HEIGHT))
//        self.chartViewHeaderView.backgroundColor = UIColor.redColor()
        var weekDayNames = [String]()
        for index in 0...self.getCapacity() - 1 {
//            let finishedValue = self.data[2 * index]
            let finishedValue = self.data[index]
//            let breakedValue = self.data[2 * index + 1]
            let breakedValue: CGFloat = 0
            if finishedValue + breakedValue == 0 {
                if index == currentIndex {
                    weekDayNames.append("0%")
                } else {
                    weekDayNames.append("-")
                }
            } else if finishedValue == 0 {
                weekDayNames.append("0%")
            } else {
                let percentage = finishedValue / (finishedValue + breakedValue)
                let str = "\(Int(percentage * 100))%"
                weekDayNames.append(str)
            }
        }
        
        if weekDayNames.count <= 0 {
            weekDayNames.append("0%")
        }
        
        while weekDayNames.count > 0 && weekDayNames[weekDayNames.count - 1] == "-" {
            weekDayNames.removeAtIndex(weekDayNames.count - 1)
        }
        
        if weekDayNames.count <= 0 {
            return
        }
        
        for index in 0...weekDayNames.count - 1 {
            let tempLabel = UILabel()
            tempLabel.text = weekDayNames[index]
            let capacity = self.getCapacity()
            let itemWidth: CGFloat = chartViewHeaderView.frame.width / CGFloat(capacity)
            
            var y = VIEW_HEIGHT - LABEL_HEIGHT
            let finishedValue = self.data[2 * index]
            let breakedValue = self.data[2 * index + 1]
            let value = max(finishedValue, breakedValue)
            if value > 0 {
//                let maximumValue = self.chartView.maximumValue
                let result = value / self.maximumHeight
                y -= result * 157
            }
            
            tempLabel.frame = CGRectMake(itemWidth * CGFloat(index), y, itemWidth, LABEL_HEIGHT)
            tempLabel.textColor = UIColor.whiteColor()
            tempLabel.font = UIFont.systemFontOfSize(12)
            tempLabel.textAlignment = NSTextAlignment.Center
            chartViewHeaderView.addSubview(tempLabel)
        }
        
        self.setChartViewHeaderViewVisible(false, withAmination: false)
        
        self.statisticsView.insertSubview(self.chartViewHeaderView, belowSubview: self.chartView)
        chartViewHeaderView.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.statisticsView.mas_centerX)
            make.top.equalTo()(self.statisticsView.mas_top).offset()
            make.width.equalTo()(self.chartView.frame.width+50)
            make.height.equalTo()(VIEW_HEIGHT)
            return ()
        }
    }
    
    */
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            if WARDevice.getPhoneType() == PhoneType.iPhone4 {
                return 1
            }
            return 15
        }
        return 0.01
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 300
        }
        if indexPath.section == 1 {
            return 44
        }
        return 0
    }
    
    // MARK: - JBBarChartViewDelegate
    
    func numberOfBarsInBarChartView(barChartView: JBBarChartView!) -> UInt {
        return UInt(self.getNumberOfBarsByPhoneSize())
    }
    
    func getNumberOfBarsByPhoneSize() -> Int {
//        switch WARDevice.getPhoneType() {
//        case .iPhone4, .iPhone5:
//            return 6
//            
//        case .iPhone6, .iPhone6Plus:
//            return 8
//            
//        default:
//            return 0
//        }
        return self.getCapacity()
    }
    
    // MARK: - JBBarChartViewDataSource
    
    func barChartView(barChartView: JBBarChartView!, heightForBarViewAtIndex index: UInt) -> CGFloat {
        return self.data[Int(index)]
    }
    
    func barChartView(barChartView: JBBarChartView!, colorForBarViewAtIndex index: UInt) -> UIColor! {
//        return index % 2 == 0 ?
//            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9) :
//            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.6)
        return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9)
    }
    
    func barPaddingForBarChartView(barChartView: JBBarChartView!) -> CGFloat {
        let barNumber = CGFloat(self.getNumberOfBarsByPhoneSize())
        return (barChartView.frame.width - (barNumber * 15)) / ((barNumber - 1))
    }
//
//    func barGroupPaddingForBarChartView(barChatView: JBBarChartView!) -> CGFloat {
//        return 50.0
//    }
//    
//    
    
//    func itemsCountInOneGroup() -> Int32 {
//        return 2
//    }
//    


    func barChartView(barChartView: JBBarChartView!, didSelectBarAtIndex index: UInt) {
       // self.setCommentsViewVisible(false)
        //self.setTooltipVisible(true, animated: true, atIndex: Int(index))
        //self.setChartViewHeaderViewVisible(false, withAmination: true)
        //self.setTooltipValue(self.data[Int(index)])
    }
    
    func didDeselectBarChartView(barChartView: JBBarChartView!) {
        //self.setCommentsViewVisible(true)
//        self.setChartViewHeaderViewVisible(true, withAmination: true)
        //self.tooltip.alpha = 0.0
    }
    /*
    func setTooltipValue(value: CGFloat) {
        self.tooltip.text = "\(Int(value))"
    }
    
    func setTooltipVisible(visible: Bool, animated:Bool, atIndex index: Int) {
        if self.tooltip == nil {
//            self.tooltip = UIView(frame: CGRectMake(0, 0, 16, 8))
            self.tooltip = UILabel(frame: CGRectMake(0, 0, 30, 10))
//            self.tooltip.backgroundColor = UIColor.redColor()
            self.tooltip.font = UIFont.systemFontOfSize(12)
            self.tooltip.textColor = UIColor.whiteColor()
            self.tooltip.textAlignment = NSTextAlignment.Center
            
            self.statisticsView.addSubview(self.tooltip)
        }
        
        let adjustTooltipPosition:() -> Void = {
            let spaceWidth = (self.getCapacity() - 1) * 50 + self.getCapacity() * 10
            let itemWidth = (self.chartView.frame.size.width - CGFloat(spaceWidth)) / CGFloat(self.getCapacity() * 2)

            let itemSpace = ceil(CGFloat(index) / 2) * 10
            let groupSpace = CGFloat(index / 2) * 50
            let itemsWidth = CGFloat(index) * itemWidth
            let x: CGFloat = (self.statisticsView.frame.size.width - self.chartView.frame.size.width) / 2 + itemSpace + groupSpace + itemsWidth
            self.tooltip.frame = CGRectMake(CGFloat(x - (self.tooltip.frame.size.width - itemWidth) / 2), 20, self.tooltip.frame.size.width, self.tooltip.frame.size.height)
        }
        
        let adjustTooltipVisibility:() -> Void = {
            self.tooltip.alpha = visible ? 1.0 : 0.0
        }
        
        if animated {
            adjustTooltipPosition()
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                adjustTooltipVisibility()
            }, completion: { (finished) -> Void in
            })
        } else {
            adjustTooltipVisibility()
        }
    }
    */
    // MARK: - StatisticsLockerDelegate
    
    func statisticsLockerDidClickedBuyButton(sender: StatisticsLocker) {
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue(), {
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            return
        })

        ProductsManager.sharedInstance.purchasePro()
    }
    
    // MARK: - ProductsManagerDelegate
    
    func productsManager(productsManager: ProductsManager, paymentTransactionState state: SKPaymentTransactionState) {
        switch state {
        case SKPaymentTransactionState.Purchased:
            print("ProductsManagerDelegate - Purchased")
            break
            
        case SKPaymentTransactionState.Restored:
            print("ProductsManagerDelegate - Restored")
            break
            
        case SKPaymentTransactionState.Failed:
            print("ProductsManagerDelegate - Failed")
            break
            
        default:
            break
        }
        let versionType = ApplicationStateManager.sharedInstance.versionType()
        if versionType == .Pro {
            self.showProAlert()
            self.locker?.removeFromSuperview()
        }
    }
    
    func showProAlert() {
        self.showCheckMarkHUDWithText("Update Succeeded")
    }
    
    func showCheckMarkHUDWithText(text: String) {
        let thanksHUD = MBProgressHUD(view: self.view)
        thanksHUD.customView = UIImageView(image: UIImage(named: "checkmark"))
        thanksHUD.mode = MBProgressHUDMode.CustomView
        thanksHUD.labelText = text
        self.view.addSubview(thanksHUD)
        thanksHUD.show(true)
        thanksHUD.hide(true, afterDelay: 2.5)
    }
}






























