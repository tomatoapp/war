//
//  StatisticsViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/20.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

class StatisticsViewController: BaseTableViewController, JBBarChartViewDelegate, JBBarChartViewDataSource {
    
    @IBOutlet var rateSwitch: UISwitch!
    @IBOutlet var showPercentageSwitch: UISwitch!
    @IBOutlet var statisticsView: UIView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    var chatType =  TimeSpanType.Month
    var chartView: JBBarChartView!
    var chartViewFooterView: UIView!
    var data = [CGFloat]()
    var baseData: [Int: Array<Work>] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var frame: CGRect!
        
        switch WARDevice.getPhoneType() {
        case .iPhone4, .iPhone5:
            frame = CGRectMake(0, 0, 222, 157)
            break
            
        case .iPhone6, .iPhone6Plus:
            frame = CGRectMake(0, 0, 311, 157)
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
    }
    
    func setStateToExpanded() {
        self.chartView.reloadData()
        self.chartView.setState(.Expanded, animated: true)
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
        
        self.loaDataSourceBySegmentedControlSelectedIndex(self.segmentedControl.selectedSegmentIndex)
        self.chartView.reloadData()
    }
    
    // MARK: - Events
    
    @IBAction func rateSwitchValueChanged(sender: AnyObject) {
        
    }
    
    @IBAction func showPercentageSwitchValueChanged(sender: AnyObject) {
    }
    
    @IBAction func segmentControlValueChanged(sender: AnyObject) {
        self.loaDataSourceBySegmentedControlSelectedIndex((sender as UISegmentedControl).selectedSegmentIndex)
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
        self.loadDataSourceByType(type)
        self.removeFooterViewFromTheStatisticsView()
        self.addFooterViewToTheStatisticsView(type)
    }
    
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
            self.data.insert(CGFloat(stopedCount), atIndex: 1)
        }
        
        // 1. Remove the zero item from the top of the data source.
        while self.data.count >= 2 && (self.data[0] == 0 && self.data[1] == 0) {
            self.data.removeAtIndex(0)
            self.data.removeAtIndex(0)
        }
        
        while self.data.count < self.getNumberOfBarsByPhoneSize() {
            self.data.append(CGFloat(0))
        }
        self.setChatViewMaximumValue(maxElement(self.data))
        self.setStateToCollapsed()
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("setStateToExpanded"), userInfo: nil, repeats: false)
    }
    
    func getCapacity() -> Int {
        if WARDevice.getPhoneType() == .iPhone6 || WARDevice.getPhoneType() == .iPhone6Plus {
            return 3
        }
        return 2
    }
    
    func setChatViewMaximumValue(value: CGFloat) {
        if value > 20 {
            // 20 = 30 / 1.4858
            // If the value too large, then set the max height of the chat to the_max_number * 1.4858
            self.chartView.maximumValue = value * 1.4858
        } else {
            self.chartView.maximumValue = 30
        }
    }
    
    func getWorksCountWithGroup(list: Array<Work>, byType type: TimeSpanType) -> [Int: Array<Work>]{
        
        var dic = [Int: Array<Work>]()
        
        let startComponents = NSCalendar.currentCalendar().components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitWeekOfMonth | .CalendarUnitWeekday | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond , fromDate: NSDate())
        
        let endComponents = NSCalendar.currentCalendar().components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitWeekOfMonth | .CalendarUnitWeekday | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond , fromDate: NSDate())
        
        startComponents.hour = 0
        startComponents.minute = 0
        startComponents.second = 1
        endComponents.hour = 23
        endComponents.minute = 59
        startComponents.second = 59
        
        let capacity = self.getCapacity()
        
        switch type {
        case .Week:
            for i in 0...capacity {
                startComponents.day = startComponents.day - (i == 0 ? 0 : 1)
                endComponents.day = startComponents.day
                let startDate = NSCalendar.currentCalendar().dateFromComponents(startComponents)!
                let endDate = NSCalendar.currentCalendar().dateFromComponents(endComponents)!
                var result = self.filterWorks(list, byStartDate: startDate, andEndDate: endDate)
                dic[i] = result
            }
            break
            
        case .Month:
            startComponents.day = startComponents.day - startComponents.weekday + 1
            for i in 0...capacity {
                startComponents.day = startComponents.day - ((i == 0 ? 0 : 1) * 7)
                endComponents.day = startComponents.day + 6
                let startDate = NSCalendar.currentCalendar().dateFromComponents(startComponents)!
                let endDate = NSCalendar.currentCalendar().dateFromComponents(endComponents)!
                let result = self.filterWorks(list, byStartDate: startDate, andEndDate: endDate)
                dic[i] = result
            }
            break
            
        case .Year:
            startComponents.day = 1
            endComponents.day = 0
            for i in 0...capacity {
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
    
    func addFooterViewToTheStatisticsView(type: TimeSpanType) {
        let LABEL_WIDTH: CGFloat = 40
        let LABEL_HEIGHT: CGFloat = 25
        self.chartViewFooterView = UIView(frame: CGRectMake(0, 0, self.chartView.frame.width, LABEL_HEIGHT))
        
        let todayComponents = self.getComponentsByDate(NSDate())
        
        switch type {
            
        case .Week:
            var dates = [NSDate?]()
            for index in 0...self.baseData.count-1 {
                let works = self.baseData[index]! as Array<Work>
                dates.insert(works.first?.workTime, atIndex: 0)
            }
            
            while dates.count > 0 && dates[0] == nil {
                dates.removeAtIndex(0)
            }
            
            while dates.count < self.getCapacity()+1  {
                dates.append(nil)
            }
            println("datas: \(dates)")
            
            // If the dates[0] is nil, mean that all the list is nil.
            if dates[0] == nil {
                dates[0] = NSDate()
            }
            
            var todayIndex = -1
            let theFirstDateComponets = self.getComponentsByDate(dates[0])
            let result = NSCalendar.currentCalendar().components(NSCalendarUnit.DayCalendarUnit, fromDate: dates[0]!, toDate: NSDate(), options: NSCalendarOptions.allZeros)
            
            println("result.day: \(result.day)")
            
            todayIndex = result.day
            
            println("todayIndex: \(todayIndex)")
            
            // Covert the number to Week day string.
            var weekDayNames = [String]()
            weekDayNames.append("Today")
            
            // if todayIndex is zero, mean that today is the first day.
            // if todayIndex is not zero, mean that today is not the first day. maybe in the middle, and maybe in the end.
            
            if todayIndex > 0 {
                for index in 1...todayIndex {
                    weekDayNames.insert(self.getWeekDayStringByWeekDayNumber(todayComponents.weekday - index), atIndex: 0)
                }
            }
            
//            if todayIndex < (dates.count - 1) {
//                for index in (todayIndex + 1)...(dates.count - 1) {
//                    weekDayNames.append(self.getWeekDayStringByWeekDayNumber(++todayComponents.weekday))
//                }
//            }
            
            println("labels: \(weekDayNames)")
            
            for i in 0...weekDayNames.count - 1 {
                let tempLabel = UILabel()
                tempLabel.text = weekDayNames[i]
                let capacity = self.getCapacity()
                tempLabel.frame = CGRectMake(CGFloat(((Int(((chartViewFooterView.frame.width - LABEL_WIDTH) / CGFloat(capacity))) * i))), 0, LABEL_WIDTH, LABEL_HEIGHT)
                tempLabel.textColor = UIColor.whiteColor()
                tempLabel.font = UIFont.systemFontOfSize(12)
                tempLabel.textAlignment = NSTextAlignment.Center
                chartViewFooterView.addSubview(tempLabel)
            }
            
            break
            
        case .Month:
            
            var dates = [NSDate?]()
            for index in 0...self.baseData.count-1 {
                let works = self.baseData[index]! as Array<Work>
                dates.insert(works.first?.workTime, atIndex: 0)
            }
            
            while dates.count > 0 && dates[0] == nil {
                dates.removeAtIndex(0)
            }
            
            while dates.count < self.getCapacity()+1  {
                dates.append(nil)
            }
            println("dates: \(dates)")
            
            // If the dates[0] is nil, mean that all the list is nil.
            if dates[0] == nil {
                dates[0] = NSDate()
            }
            
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
            
            println("dates: \(firstDayOfTheWeekDates) (firstDayOfTheWeekDates)")
            
//            var todayIndex = -1
//            let theFirstDateComponets = self.getComponentsByDate(dates[0])
//            let result = NSCalendar.currentCalendar().components(NSCalendarUnit.DayCalendarUnit, fromDate: dates[0]!, toDate: NSDate(), options: NSCalendarOptions.allZeros)
//            
//            println("result.day: \(result.day)")
//            
//            todayIndex = result.day
//            
//            println("todayIndex: \(todayIndex)")
            
            // Covert the number to Week day string.
            var weekDayNames = [String]()
//            weekDayNames.append("Today")
//            
//            // if todayIndex is zero, mean that today is the first day.
//            // if todayIndex is not zero, mean that today is not the first day. maybe in the middle, and maybe in the end.
//            
//            if todayIndex > 0 {
//                for index in 1...todayIndex {
//                    weekDayNames.insert(self.getWeekDayStringByWeekDayNumber(todayComponents.weekday - index), atIndex: 0)
//                }
//            }
            
            for date in firstDayOfTheWeekDates {
                if date == nil {
                    weekDayNames.append("nil")
                    continue
                }
                weekDayNames.append(self.getStringByDate(date!))
            }
            
            
//            
            //            if todayIndex < (dates.count - 1) {
            //                for index in (todayIndex + 1)...(dates.count - 1) {
            //                    weekDayNames.append(self.getWeekDayStringByWeekDayNumber(++todayComponents.weekday))
            //                }
            //            }
            
            println("labels: \(weekDayNames)")
            
            for i in 0...weekDayNames.count - 1 {
                let tempLabel = UILabel()
                tempLabel.text = weekDayNames[i]
                let capacity = self.getCapacity()
                tempLabel.frame = CGRectMake(CGFloat(((Int(((chartViewFooterView.frame.width - LABEL_WIDTH) / CGFloat(capacity))) * i))), 0, LABEL_WIDTH, LABEL_HEIGHT)
                tempLabel.textColor = UIColor.whiteColor()
                tempLabel.font = UIFont.systemFontOfSize(12)
                tempLabel.textAlignment = NSTextAlignment.Center
                chartViewFooterView.addSubview(tempLabel)
            }
            
            
            break
            
        case .Year:
            break
            
        }
        self.statisticsView.addSubview(chartViewFooterView)
        chartViewFooterView.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.statisticsView.mas_centerX)
            make.bottom.equalTo()(self.statisticsView.mas_bottom).offset()(-10)
            make.width.equalTo()(self.chartView.frame.width)
            make.height.equalTo()(LABEL_HEIGHT)
            return ()
        }
    }
    
    func getWeekDayStringByWeekDayNumber(weekDay: Int) -> String {
        switch weekDay {
            
        case 1:
            return "Sun"
            
        case 2:
            return "Mon"
            
        case 3:
            return "Tue"
            
        case 4:
            return "Wed"
            
        case 5:
            return "Thu"
            
        case 6:
            return "Fri"
            
        case 7:
            return "Sat"
            
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
            return "Jan"
            
        case 2:
            return "Feb"
            
        case 3:
            return "Mar"
            
        case 4:
            return "Apr"
            
        case 5:
            return "May"
            
        case 6:
            return "Jun"
            
        case 7:
            return "Jul"
            
        case 8:
            return "Aug"
            
        case 9:
            return "Sept"
            
        case 10:
            return "Oct"
            
        case 11:
            return "Nov"
            
        case 12:
            return "Dec"
            
        default:
            if month > 12 {
                return self.getMonthStringByMonthNumber(month - 12)
            } else {
                return self.getMonthStringByMonthNumber(month + 12)
            }
        }
    }
    
    func getStringByDate(date: NSDate!) -> String {
        let components = self.getComponentsByDate(date)
        let monthStr = self.getMonthStringByMonthNumber(components.month)
        return "\(monthStr) \(components.day)"
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
        return NSCalendar.currentCalendar().components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitWeekday | .CalendarUnitWeekOfMonth | .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond, fromDate: date)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
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
        switch WARDevice.getPhoneType() {
        case .iPhone4, .iPhone5:
            return 6
            
        case .iPhone6, .iPhone6Plus:
            return 8
            
        default:
            return 0
        }
    }
    
    // MARK: - JBBarChartViewDataSource
    
    func barChartView(barChartView: JBBarChartView!, heightForBarViewAtIndex index: UInt) -> CGFloat {
        return self.data[Int(index)]
    }
    
    func barChartView(barChartView: JBBarChartView!, colorForBarViewAtIndex index: UInt) -> UIColor! {
        return index % 2 == 0 ?
            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9) :
            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.6)
    }
    
    func barPaddingForBarChartView(barChartView: JBBarChartView!) -> CGFloat {
        return 10.0
    }
    
    func barGroupPaddingForBarChartView(barChatView: JBBarChartView!) -> CGFloat {
        return 50.0
    }
    
    func itemsCountInOneGroup() -> Int32 {
        return 2
    }
}
