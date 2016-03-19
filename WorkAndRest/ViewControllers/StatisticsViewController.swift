//
//  StatisticsViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/20.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

private let ChartBarWidth: CGFloat = 15
class StatisticsViewController: BaseTableViewController, JBBarChartViewDelegate, JBBarChartViewDataSource, StatisticsLockerDelegate, ProductsManagerDelegate {
    
    @IBOutlet var statisticsView: UIView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var commentsView: UIView!
    @IBOutlet var statisticsBg: UIImageView!
    
    @IBOutlet weak var chartViewLeading: NSLayoutConstraint!
    @IBOutlet weak var chartViewTrailing: NSLayoutConstraint!
    
    var chatType =  TimeSpanType.Month
    @IBOutlet var chartView: JBBarChartView!
    @IBOutlet var chartViewFooterView: UIView!
    var chartViewHeaderView: UIView!
    var data = [CGFloat]()
    var baseData: [Int: Array<Work>] = [:]
    var tooltipVisible = false
    
    //    var tooltip: UILabel!
    var locker: StatisticsLocker?
    
    //var maximumHeight: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.needLockTheChart() {
            self.lockTheChart()
        } else {
            self.locker?.removeFromSuperview()
        }
        self.loaDataSourceBySegmentedControlSelectedIndex(self.segmentedControl.selectedSegmentIndex)
        
        //self.chartView.reloadData()
        
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
            type = .Week
            break
            
        case 1:
            type = .Month
            break
            
        case 2:
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
        
        self.chartViewLeading.constant = (self.barPaddingForBarChartView() / 2)
        self.chartViewTrailing.constant = (self.barPaddingForBarChartView() / 2)
        
        for label in self.tooltips {
            label.removeFromSuperview()
        }
        self.setTooltipValue()
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
            return 4//4*2
            
        case .Year:
            return 6//12
        }
    }
    
    func getMaximumChartViewHeightByValue(value: CGFloat) -> CGFloat {
        if value > 20 {
            // 20 = 30 / 1.4858
            // If the value too large, then set the max height of the chat to the_max_number * 1.4858
            return value * 1.4858
        } else {
            return 30
        }
    }
    func setChatViewMaximumValue(value: CGFloat) {
        
        self.chartView.maximumValue = self.getMaximumChartViewHeightByValue(value)
    }
    
    // Get today
    func getTodayComponents() -> NSDateComponents {
        return NSCalendar.currentCalendar().components([.Year, .Month, .WeekOfMonth, .Weekday, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second] , fromDate: NSDate())
    }
    
    // Get a fist-second-of-one-day date
    // like: 2016-3-6 00:00:01
    func getFirstSecondComponents(components: NSDateComponents) -> NSDateComponents {
        let firstSecondComponents = components.copy() as! NSDateComponents
        firstSecondComponents.hour = 0
        firstSecondComponents.minute = 0
        firstSecondComponents.second = 1
        return firstSecondComponents
    }
    
    // Get a last-second-of-one-day date
    // like: 2016-3-6 23:59:59
    func getLastSecondComponents(components: NSDateComponents) -> NSDateComponents {
        let lastSecondComponents = components.copy() as! NSDateComponents
        lastSecondComponents.hour = 23
        lastSecondComponents.minute = 59
        lastSecondComponents.second = 59
        return lastSecondComponents
    }
    
    // Get the date string with UTC+8 timeZone.
    func getLocalDateString(date: NSDate) -> String {
        let dateFormater = NSDateFormatter()
        // Default timeZone is the current timeZone, UTC+8, so you can comment this line of code:
        // dateFormater.timeZone = NSTimeZone(name: "UTC+8")
        dateFormater.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormater.stringFromDate(date)
    }
    
    func getWorksCountWithGroup(list: Array<Work>, byType type: TimeSpanType) -> [Int: Array<Work>]{
        
        var dic = [Int: Array<Work>]()
        let now = self.getTodayComponents()
        let start = getFirstSecondComponents(now)
        let end = getLastSecondComponents(now)
        
        let capacity = self.getCapacity()
        
        switch type {
        case .Week:
            for i in 0...capacity-1 {
                start.day = start.day - (i == 0 ? 0 : 1)
                end.day = start.day
                let startDate = NSCalendar.currentCalendar().dateFromComponents(start)!
                let endDate = NSCalendar.currentCalendar().dateFromComponents(end)!
                print("\(self.getLocalDateString(startDate)) ~ \(self.getLocalDateString(endDate))  \(i)")
                let result = self.filterWorks(list, byStartDate: startDate, andEndDate: endDate)
                dic[i] = result
            }
            break
            
        case .Month:
            start.day = start.day - start.weekday + 1
            for i in 0...capacity-1 {
                start.day = start.day - ((i == 0 ? 0 : 1) * 7)
                if self.isZhHans() {
                    start.day += 1
                }
                end.day = start.day + 6
                let startDate = NSCalendar.currentCalendar().dateFromComponents(start)!
                let endDate = NSCalendar.currentCalendar().dateFromComponents(end)!
                print("\(self.getLocalDateString(startDate)) ~ \(self.getLocalDateString(endDate))  \(i)")
                let result = self.filterWorks(list, byStartDate: startDate, andEndDate: endDate)
                dic[i] = result
            }
            break
            
        case .Year:
            start.day = 1
            end.day = 0
            for i in 0...capacity-1 {
                start.month = start.month - (i == 0 ? 0 : 1)
                end.month = start.month + 1
                let startDate = NSCalendar.currentCalendar().dateFromComponents(start)!
                let endDate = NSCalendar.currentCalendar().dateFromComponents(end)!
                print("\(self.getLocalDateString(startDate)) ~ \(self.getLocalDateString(endDate))  \(i)")
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
        
        var names = [String]()
        
        // Init the footer view
        let LABEL_HEIGHT: CGFloat = 25
        self.chartViewFooterView = UIView()
        self.statisticsView.insertSubview(chartViewFooterView, belowSubview: self.chartView)
        chartViewFooterView.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.statisticsView.mas_centerX)
            make.bottom.equalTo()(self.statisticsView.mas_bottom).offset()(-10)
            make.width.equalTo()(self.statisticsView.mas_width)
            make.height.equalTo()(LABEL_HEIGHT)
        }
        
        let now = self.getTodayComponents()
        let start = getFirstSecondComponents(now)
        let end = getLastSecondComponents(now)
        let capacity = self.getCapacity()
        
        switch type {
            
        case .Week:
            for i in 0...((self.getCapacity() - 1) * 1) {
                let day = NSDate().addDays(-i)
                if i == (self.getCapacity() - 1) {
                    
                    // en
                    let monthStr = self.getMonthStringByMonthNumber(day.getMonth())
                    var name = "\(monthStr) d"
                    
                    // zh-Hans
                    if WARDevice.getLanguage() == "zh-Hans" {
                        name = day.toString("M月d日")
                    }
                    
                    names.insert(name, atIndex: 0)
                } else {
                    names.insert(day.toSampleString("d"), atIndex: 0)
                }
            }
            break
            
        case .Month:
            start.day = start.day - start.weekday + 1
            for i in 0...capacity-1 {
                start.day = start.day - ((i == 0 ? 0 : 1) * 7)
                if self.isZhHans() {
                    start.day += 1
                }
                end.day = start.day + 6
                let startDate = NSCalendar.currentCalendar().dateFromComponents(start)!
                let endDate = NSCalendar.currentCalendar().dateFromComponents(end)!
                
                // en
                let startMonthString = self.getMonthStringByMonthNumber(startDate.getMonth())
                var startDateString = "\(startMonthString) d"
                // cn
                if self.isZhHans() {
                    startDateString = startDate.toString("M月d日")
                }
                
                //en
                let endMonthString = self.getMonthStringByMonthNumber(endDate.getMonth())
                var endDateString = "\(endMonthString) d"
                // cn
                if self.isZhHans() {
                    endDateString = endDate.toString("M月d日")
                }
                
                if startDate.isSameMonthWithDate(endDate) {
                    // en
                    endDateString = endDate.toString("d")
                    // cn
                    if self.isZhHans() {
                        endDateString = endDate.toString("d日")
                    }
                }
                
                names.insert("\(startDateString)-\(endDateString)", atIndex: 0)
            }
            
            break
            
        case .Year:
            start.day = 1
            for i in 0...capacity-1 {
                start.month = start.month - (i == 0 ? 0 : 1)
                let startDate = NSCalendar.currentCalendar().dateFromComponents(start)!
                // var dateString = startDate.toString("M月")
                // en
                var dateString = self.getMonthStringByMonthNumber(startDate.getMonth())
                // cn
                if self.isZhHans() {
                    dateString = startDate.toString("M月")
                }
                
                
                // new year || first item
                if (start.month == 1) || (i == capacity - 1) {
                    //                    dateString = startDate.toString("yyyy年M月")
                    dateString = self.getMonthStringByMonthNumber(startDate.getMonth()) + " " + startDate.toString("yyyy")
                    if self.isZhHans() {
                        dateString = startDate.toString("yyyy年M月")
                    }
                }
                names.insert("\(dateString)", atIndex: 0)
            }
            break
        }
        
        // Build the footer labels by the names
        
        print("weekDayNames - labels: \(names)")
        for index in 0...names.count - 1 {
            let tempLabel = UILabel()
            tempLabel.text = names[index]
            let capacity = self.getCapacity()
            let itemWidth: CGFloat = self.statisticsView.frame.width / CGFloat(capacity)
            tempLabel.frame = CGRectMake(itemWidth * CGFloat(index), 0, itemWidth, LABEL_HEIGHT)
            if index == names.count - 1 {
                tempLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
            } else {
                tempLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
            }
            tempLabel.font = UIFont.systemFontOfSize(10)
            tempLabel.textAlignment = NSTextAlignment.Center
            chartViewFooterView.addSubview(tempLabel)
        }
    }
    func getWeekDayStringByWeekDayNumber(weekDay: Int) -> String {
        switch weekDay {
            
        case 1:
            return NSLocalizedString("Sun", comment: "")
            
        case 2:
            return NSLocalizedString("Mon", comment: "")
            
        case 3:
            return NSLocalizedString("Tue", comment: "")
            
        case 4:
            return NSLocalizedString("Wed", comment: "")
            
        case 5:
            return NSLocalizedString("Thu", comment: "")
            
        case 6:
            return NSLocalizedString("Fri", comment: "")
            
        case 7:
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
            return NSLocalizedString("Jan", comment: "")
            
        case 2:
            return NSLocalizedString("Feb", comment: "")
            
        case 3:
            return NSLocalizedString("Mar", comment: "")
            
        case 4:
            return NSLocalizedString("Apr", comment: "")
            
        case 5:
            return NSLocalizedString("May", comment: "")
            
        case 6:
            return NSLocalizedString("Jun", comment: "")
            
        case 7:
            return NSLocalizedString("Jul", comment: "")
            
        case 8:
            return NSLocalizedString("Aug", comment: "")
            
        case 9:
            return NSLocalizedString("Sept", comment: "")
            
        case 10:
            return NSLocalizedString("Oct", comment: "")
            
        case 11:
            return NSLocalizedString("Nov", comment: "")
            
        case 12:
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
        
        calendar.rangeOfUnit(.Day, startDate: &fromDate, interval: &duration, forDate: date1)
        calendar.rangeOfUnit(.Day, startDate: &toDate, interval: &duration, forDate: date2)
        
        let difference = calendar.components(.Day, fromDate: fromDate!, toDate: toDate!, options: [])
        return difference.day
    }
    
    func weeksBetweenDateFromDate(date1: NSDate, toDate date2: NSDate) -> Int {
        var fromDate: NSDate?
        var toDate: NSDate?
        var duration: NSTimeInterval = 0
        
        let calendar = NSCalendar.currentCalendar()
        
        calendar.rangeOfUnit(.WeekOfYear, startDate: &fromDate, interval: &duration, forDate: date1)
        calendar.rangeOfUnit(.WeekOfYear, startDate: &toDate, interval: &duration, forDate: date2)
        
        let difference = calendar.components(.WeekOfYear, fromDate: fromDate!, toDate: toDate!, options: [])
        return difference.weekOfYear
    }
    
    func monthsBetweenDateFromDate(date1: NSDate, toDate date2: NSDate) -> Int {
        var fromDate: NSDate?
        var toDate: NSDate?
        var duration: NSTimeInterval = 0
        
        let calendar = NSCalendar.currentCalendar()
        
        calendar.rangeOfUnit(.Month, startDate: &fromDate, interval: &duration, forDate: date1)
        calendar.rangeOfUnit(.Month, startDate: &toDate, interval: &duration, forDate: date2)
        
        let difference = calendar.components(.Month, fromDate: fromDate!, toDate: toDate!, options: [])
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
        return self.barPaddingForBarChartView()
    }
    
    func barPaddingForBarChartView() -> CGFloat {
        let barNumber = CGFloat(self.getNumberOfBarsByPhoneSize())
        let result = (self.statisticsView.frame.width - (barNumber * ChartBarWidth)) / (barNumber * 2) * 2
        print("self.statisticsView.frame.width : \(self.statisticsView.frame.width)")
        print("result: \(result)")
        return result
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
        // self.setTooltipValue(self.data[Int(index)])
    }
    
    func didDeselectBarChartView(barChartView: JBBarChartView!) {
        //self.setCommentsViewVisible(true)
        //        self.setChartViewHeaderViewVisible(true, withAmination: true)
        //self.tooltip.alpha = 0.0
    }
    
    var tooltips = Array<UILabel>()
    func setTooltipValue() {
        let LABEL_HEIGHT: CGFloat = 10
        for index in 0...self.getCapacity() - 1 {
            let value = self.data[Int(index)]
            if value <= 0 {
                continue
            }
            let tooltip = UILabel()
            tooltip.text = "🍅×\(Int(value))"
            tooltip.font = UIFont.systemFontOfSize(8)
            tooltip.textColor = UIColor.whiteColor()
            tooltip.textAlignment = .Center
            let itemWidth: CGFloat = self.statisticsView.frame.width / CGFloat(self.getCapacity())
            let x: CGFloat = itemWidth * CGFloat(index)
            let itemBarHeight = value
            var y: CGFloat = self.chartView.frame.size.height - LABEL_HEIGHT
            let result = itemBarHeight / self.getMaximumChartViewHeightByValue(itemBarHeight)
            y -= result * self.chartView.frame.size.height
            tooltip.frame = CGRectMake(x, y, itemWidth, LABEL_HEIGHT)
            self.statisticsView.addSubview(tooltip)
            tooltip.alpha = 0.0
            UIView.animateWithDuration(0.0, delay: 0.55, options: .BeginFromCurrentState, animations: { () -> Void in
                tooltip.alpha = 1.0
                
                }, completion: nil)
            tooltips.append(tooltip)
        }
    }
    /*
    
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
    
    func isZhHans() -> Bool {
        return WARDevice.getLanguage() == "zh-Hans"
    }
}






























