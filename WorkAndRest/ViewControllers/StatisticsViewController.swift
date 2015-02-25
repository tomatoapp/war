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
    var chatView: JBBarChartView!
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
        self.chatView = JBBarChartView(frame: frame)
        self.statisticsView.addSubview(self.chatView)
        
        self.chatView.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.statisticsView.mas_centerX)
            make.centerY.equalTo()(self.statisticsView.mas_centerY).offset()(-17)
            make.width.equalTo()(frame.size.width)
            make.height.equalTo()(frame.size.height)
            return ()
        }
        
        self.chatView.delegate = self
        self.chatView.dataSource = self
        self.chatView.minimumValue = 0.0
    }
    
    func setStateToExpanded() {
        self.chatView.reloadData()
        self.chatView.setState(.Expanded, animated: true)
    }
    
    func setStateToCollapsed() {
        self.chatView.setState(.Collapsed, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loaDataSourceBySegmentedControlSelectedIndex(self.segmentedControl.selectedSegmentIndex)
        self.chatView.reloadData()
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
        self.addDateFooterLabelToTheChartViewByType(type)
    }
    
    func loadDataSourceByType(type: TimeSpanType) {
        
        let allTasks = WorkManager.sharedInstance.selectWorksByTimeType(type)
        self.data.removeAll(keepCapacity: false)
        
        let dic = self.getWorksCountWithGroup(allTasks, byType: type)
        self.baseData = dic
        for index in 0...dic.count-1 {
            let works = dic[index]! as Array<Work>
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
        
        // Move the zero to the end of the data souce:
        // 1. Remove the zero from the top of the data source.
        while self.data.count >= 2 && (self.data[0] == 0 && self.data[1] == 0) {
            self.data.removeAtIndex(0)
            self.data.removeAtIndex(0)
        }
        // 2. Add the zero to the end of the data source.
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
            self.chatView.maximumValue = value * 1.4858
        } else {
            self.chatView.maximumValue = 30
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
    
    func addDateFooterLabelToTheChartViewByType(type: TimeSpanType) {
        let LABEL_WIDTH: CGFloat = 40
        let LABEL_HEIGHT: CGFloat = 25
        let baseContainerView = UIView(frame: CGRectMake(0, 0, self.chatView.frame.width, LABEL_HEIGHT))
        
        let components = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitWeekday | NSCalendarUnit.CalendarUnitDay, fromDate: NSDate())
        switch type {
        case .Week:
            for i in 0...self.getCapacity() {
                let tempLabel = UILabel()
                components.weekday -= (i == 0 ? 0 : 1)
                println("\(self.getWeekDayStringByWeekDayNumber(components.weekday))")
                tempLabel.text = self.getWeekDayStringByWeekDayNumber(components.weekday)
                let capacity = self.getCapacity()
                tempLabel.frame = CGRectMake(CGFloat(((Int(((baseContainerView.frame.width - LABEL_WIDTH) / CGFloat(capacity))) * i))), 0, LABEL_WIDTH, LABEL_HEIGHT)
                tempLabel.textColor = UIColor.whiteColor()
                tempLabel.font = UIFont.systemFontOfSize(12)
                tempLabel.textAlignment = NSTextAlignment.Center
                baseContainerView.addSubview(tempLabel)
            }
            break
            
        case .Month:
            break
            
        case .Year:
            break
            
        }
        self.statisticsView.addSubview(baseContainerView)
        baseContainerView.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.statisticsView.mas_centerX)
            make.bottom.equalTo()(self.statisticsView.mas_bottom)
            make.width.equalTo()(self.chatView.frame.width)
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
            return "Unk"
        }
    }
    
    func addPercentageLabelToTheChartView() {
        
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
