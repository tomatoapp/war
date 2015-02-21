//
//  StatisticsViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/20.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

class StatisticsViewController: BaseTableViewController {

    @IBOutlet var rateSwitch: UISwitch!
    @IBOutlet var showPercentageSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.changeTheSwitchControlSmaller(self.rateSwitch)
        self.changeTheSwitchControlSmaller(self.showPercentageSwitch)
        
        println("\(self.tableView.sectionIndexColor)")
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

}
