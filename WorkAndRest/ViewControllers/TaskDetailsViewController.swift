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
    var state = TaskState.Normal
    var isAnimation = false
    
    @IBOutlet var taskItemBaseView: TaskItemBaseView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.taskItemBaseView.delegate = self
        self.taskItemBaseView.refreshTitle(self.taskItem.title)
//        self.taskRunner?.taskItem = self.taskItem
        
        if self.state == TaskState.Normal {
            self.taskItemBaseView.seconds = self.taskItem!.minutes * 60
        }
        
        isAnimation = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.taskRunner.state == .Running {
            
            if  self.taskRunner.runningTaskID() == self.taskItem.taskId { // the running task is this task
                self.started(self.taskRunner)
            } else { // the running task is other task
                self.taskItemBaseView.disable()
            }
        }
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
    
    func started(sender: TaskRunner!) {
        self.state = .Running
        self.taskItemBaseView.refreshViewBySeconds(sender.seconds)
        self.taskItemBaseView.refreshViewByState(self.state, animation:isAnimation)
    }
    
    func completed(sender: TaskRunner!) {
        self.state = .Normal
        self.taskItemBaseView.refreshViewByState(self.state)
    }
    
    func breaked(sender: TaskRunner!) {
        self.state = .Normal
        self.taskItemBaseView.refreshViewByState(self.state)
    }
    
    func tick(sender: TaskRunner!) {
        println("TaskListViewController: \(sender.seconds)")
        self.taskItemBaseView.refreshViewBySeconds(sender.seconds)
    }
    
    // MARK: - TaskItemBaseViewDelegate
    
    func taskItemBaseView(view: UIView!, buttonClicked sender: UIButton!) {
       self.start()
    }
    
    // MARK: - Methods
    
    func start() {
        self.state = .Running
        if !self.taskRunner.canStart() {
            println("Can not start!")
            return
        }
        self.taskRunner.setupTaskItem(self.taskItem)
        taskRunner.start()
    }
}
