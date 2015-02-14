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
    var taskManager = TaskManager.sharedInstance
    
    @IBOutlet var taskItemBaseView: TaskItemBaseView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.taskItemBaseView.delegate = self
        self.taskItemBaseView.isBreakButtonEnable = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.taskItemBaseView.refreshTitle(self.taskItem.title)
        
        if self.taskRunner.state == .Running {
            
            if self.taskRunner.runningTaskID() == self.taskItem.taskId { // the running task is this task
                self.taskItemBaseView.refreshViewBySeconds(self.taskRunner.seconds)
                self.taskItemBaseView.refreshViewByState(.Running, animation:false)
                
            } else { // the running task is other task
                if self.taskItem.completed {
                    self.taskItemBaseView.refreshViewByState(TaskState.Completed, animation: false)
                    //self.taskItemBaseView.disableWithTaskState(TaskState.Completed, animation: false)
                } else {
                    self.taskItemBaseView.refreshViewByState(TaskState.Normal, animation: false)
                    self.taskItemBaseView.disableWithTaskState(TaskState.Normal, animation: false)
                }
            }
        } else {
            if self.taskItem.completed {
                self.taskItemBaseView.refreshViewByState(.Completed, animation:false)
            } else {
                self.taskItemBaseView.refreshViewByState(.Normal, animation:false)
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    //    override func viewWillLayoutSubviews() {
    //        super.viewWillLayoutSubviews()
    //        self.taskItemBaseView.updateViewsWidth()
    //    }
    
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
        self.taskItemBaseView.refreshViewBySeconds(sender.seconds)
        self.taskItemBaseView.refreshViewByState(.Running)
    }
    
    func completed(sender: TaskRunner!) {
        self.taskItemBaseView.refreshViewByState(.Normal)
    }
    
    func breaked(sender: TaskRunner!) {
        self.taskItemBaseView.refreshViewByState(.Normal)
    }
    
    func tick(sender: TaskRunner!) {
        println("TaskDetailsViewController: \(sender.seconds)")
        if self.taskItemBaseView  == nil {
            return
        }
        self.taskItemBaseView.refreshViewBySeconds(sender.seconds)
    }
    
    // MARK: - TaskItemBaseViewDelegate
    
    func taskItemBaseView(view: UIView!, buttonClicked sender: UIButton!) {
        
        if self.taskItem.completed {
            // If the task is completed, then you can active it.
//            self.taskItem.completed = false
//            DBOperate.updateTask(self.taskItem)
            self.taskManager.activeTask(self.taskItem)
            
            // If some other task is running, you can't start the actived stask.
            if self.taskRunner.state == .Running {
                self.taskItemBaseView.disableWithTaskState(TaskState.Normal, animation: true)
            } else {
                self.taskItemBaseView.refreshViewByState(TaskState.Normal, animation: true)
            }
            return
        }
        
        // This is a normal task.
        
        // But perhaps some task is running, and the running task mebye just youself.
        if self.taskRunner.state == .Running {
            
            if self.taskRunner.runningTaskID() == self.taskItem.taskId {
                self.taskRunner.stop()
            } else {
                println("Some other task is running, you can do nothing")
            }
            return
        }
        
        // This is a normal task and this is no a running task, so start it now! setup the task and go!
        self.taskRunner.setupTaskItem(self.taskItem)
        if self.taskRunner.canStart() {
            self.taskRunner.start()
//            self.taskItem!.lastUpdateTime = NSDate()
//            DBOperate.updateTask(self.taskItem!)
            self.taskManager.startTask(self.taskItem!)
        }
    }
}
