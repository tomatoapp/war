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
    //var state = TaskState.Normal
    
    @IBOutlet var taskItemBaseView: TaskItemBaseView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.taskItemBaseView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.taskItemBaseView.refreshTitle(self.taskItem.title)

        if self.taskRunner.state == .Running {
            
            if self.taskRunner.runningTaskID() == self.taskItem.taskId { // the running task is this task
                self.taskItemBaseView.refreshViewBySeconds(self.taskRunner.seconds)
                
                if self.taskItem.completed {
                    self.taskItemBaseView.refreshViewByState(.Completed, animation:false)
                } else {
                    self.taskItemBaseView.refreshViewByState(.Running, animation:false)
                }
            } else { // the running task is other task
                self.taskItemBaseView.disable(animation: false)
            }
        } else {
            self.taskItemBaseView.refreshViewByState(.Normal, animation:false)
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
        //self.state = .Running
        self.taskItemBaseView.refreshViewBySeconds(sender.seconds)
        self.taskItemBaseView.refreshViewByState(.Running)
    }
    
    func completed(sender: TaskRunner!) {
        //self.state = .Normal
        self.taskItemBaseView.refreshViewByState(.Normal)
    }
    
    func breaked(sender: TaskRunner!) {
        //self.state = .Normal
        self.taskItemBaseView.refreshViewByState(.Normal)
    }
    
    func tick(sender: TaskRunner!) {
        println("TaskDetailsViewController: \(sender.seconds)")
        self.taskItemBaseView.refreshViewBySeconds(sender.seconds)
    }
    
    // MARK: - TaskItemBaseViewDelegate
    
    func taskItemBaseView(view: UIView!, buttonClicked sender: UIButton!) {
        
        if self.taskItem.completed {
            return
        }

        if self.taskRunner.state == .Running && self.taskRunner.runningTaskID() != self.taskItem.taskId {
            println("Some other task is running, you can not stop it!")
            return
        }

        if self.taskRunner.state == .Running {
            self.breakIt()
        } else if self.taskRunner.state == .UnReady {
            self.start()
        }
    }
    
    // MARK: - Methods
    
    func start() {
        self.taskRunner.setupTaskItem(self.taskItem)
        if self.taskRunner.canStart() {
            taskRunner.start()
        }
    }
    
    func breakIt() {
        self.taskRunner.stop()
        
    }
}
