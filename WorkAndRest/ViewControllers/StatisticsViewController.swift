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
    
    var chatView: JBBarChartView!
    var data = [CGFloat]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.changeTheSwitchControlSmaller(self.rateSwitch)
        self.changeTheSwitchControlSmaller(self.showPercentageSwitch)
        
        
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
        self.chatView.maximumValue = 200
        
        self.reloadDataSource()
        self.chatView.reloadData()
    }
    
    func reloadDataSource() {
        self.data = [CGFloat]()
        for _ in 0...10 {
            self.data.append(CGFloat(arc4random_uniform(100)))
        }
    }

    func setStateToExpanded() {
        self.reloadDataSource()
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
    
    // MARK: - Events
    
    @IBAction func rateSwitchValueChanged(sender: AnyObject) {
        
    }
    
    @IBAction func showPercentageSwitchValueChanged(sender: AnyObject) {
    }

    @IBAction func segmentControlValueChanged(sender: AnyObject) {
        switch (sender as UISegmentedControl).selectedSegmentIndex {
        case 0:
            // Week

            break
            
        case 1:
            // Month

            break
            
        case 2:
            // Year
            break
            
        default:
            break
        }
        self.setStateToCollapsed()
        
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("setStateToExpanded"), userInfo: nil, repeats: false)
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 15
        }
        return 0.01
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        println("\(view.backgroundColor)")
    }

    // MARK: - Methods
    
    func changeTheSwitchControlSmaller(control: UISwitch) {
        control.transform = CGAffineTransformMakeScale(0.80, 0.80)
    }
    
    // MARK: - JBBarChartViewDelegate
    
    func numberOfBarsInBarChartView(barChartView: JBBarChartView!) -> UInt {
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
        return UIColor(red: 211/255, green: 235/255, blue: 225/255, alpha: 1)
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
