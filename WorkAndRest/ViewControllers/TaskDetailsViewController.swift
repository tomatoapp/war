//
//  TaskDetailsViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/10.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

class TaskDetailsViewController: BaseTableViewController, TaskRunnerDelegate, TaskItemBaseViewDelegate {

    var taskItem: Task!
    var taskRunner: TaskRunner!
    
    @IBOutlet var taskItemBaseView: TaskItemBaseView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.taskItemBaseView.delegate = self
        self.taskItemBaseView.refreshTitle(self.taskItem.title)
        self.taskRunner.taskItem = self.taskItem
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.taskRunner.removeDelegate(self)
    }
    

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.taskItemBaseView.updateViewsWidth()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            if WARDevice.getPhoneType() == PhoneType.iPhone4 {
                return 80
            } else if WARDevice.getPhoneType() == PhoneType.iPhone5 {
                return 130
            }else if WARDevice.getPhoneType() == PhoneType.iPhone6 {
                return 160
            } else if WARDevice.getPhoneType() == PhoneType.iPhone6Plus {
                return 190
            }
        } else if indexPath.row == 4 {
            if WARDevice.getPhoneType() == PhoneType.iPhone4 {
                return 250
            } else if WARDevice.getPhoneType() == PhoneType.iPhone5 {
                return 260
            } else {
                return 274
            }
        }
        return 30
    }
    
    // MARK: - TaskRunnerDelegate
    
    func completed(sender: TaskRunner!) {
        self.taskItemBaseView.refreshViewByState(.Normal)
    }
    
    func breaked(sender: TaskRunner!) {
        self.taskItemBaseView.refreshViewByState(.Normal)
    }
    
    func tick(sender: TaskRunner!) {
        println("TaskListViewController: \(sender.seconds)")

        self.taskItemBaseView.refreshViewBySeconds(sender.seconds)
    }
    
    // MARK: - TaskItemBaseViewDelegate
    
    func taskItemBaseView(view: UIView!, buttonClicked sender: UIButton!) {

        taskRunner!.start()
        
        self.taskItemBaseView.seconds = self.taskItem!.minutes * 60
        self.taskItemBaseView.refreshViewByState(TaskState.Running)
    }
    
    // MARK: - Methods
    
}
