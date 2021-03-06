//
//  TaskListItemCell.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/30.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

protocol TaskListItemCellDelegate {
    func ready(sender: TaskListItemCell!)
    func tick(sender: TaskListItemCell!, seconds: Int)
    func completed(sender: TaskListItemCell!)
    func breaked(sender: TaskListItemCell!)
    func activated(sender: TaskListItemCell!)
    
    func quickFinish(sender: TaskListItemCell)
}

class TaskListItemCell: SWTableViewCell, TaskRunnerDelegate, TaskItemBaseViewDelegate {
    
    @IBOutlet var tempView: UIView!
    @IBOutlet var taskItemBaseView: TaskItemBaseView!
    @IBOutlet var pointImageView: UIImageView!
    
    var ANIMATION_DURATION = 0.3
    var seconds = 0
    var taskItem: Task?
    var taskRunner: TaskRunner?
    var custom_delegate: TaskListItemCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func startButton() -> UIButton {
        return taskItemBaseView.button
    }
    
    func refresh() {
        self.taskItemBaseView.refreshTitle(self.taskItem!.title)
        self.taskItemBaseView.refreshCompletedCount(self.taskItem!.finished_times)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
    }
    
    func setup() {
        self.taskItemBaseView.delegate = self
    }
    
    func start() {
        
        if !self.taskRunner!.canStart() {
            print("Can not start!")
            return
        }
        self.taskRunner!.start()
//        self.taskRunner!.taskItem.lastUpdateTime = NSDate()
//        DBOperate.updateTask(self.taskRunner!.taskItem)
        TaskManager.sharedInstance.startTask(self.taskRunner!.taskItem)
    }
    
    func breakIt() {
        self.taskRunner!.stop()
    }
    
    func disable(state: TaskState, animation: Bool) {
        if self.taskItem!.completed {
            self.taskItemBaseView.disableWithTaskState(state, animation: animation)
        } else {
            self.taskItemBaseView.disableWithTaskState(state, animation: animation)
        }
    }
    
    func reset(state: TaskState, animation: Bool = true) {
        self.taskItemBaseView.refreshViewByState(state, animation: animation)
        
        UIView.transitionWithView(self.pointImageView,
            duration: ANIMATION_DURATION,
            options: .TransitionCrossDissolve,
            animations: { () -> Void in
                
                if self.taskItem!.completed {
                    self.pointImageView.image = UIImage(named: "point_gray")
                } else {
                    self.pointImageView.image = UIImage(named: "point_yellow")
                }
            }, completion: nil)
    }
    
    func changeImageWithAnimations(view: UIView, duration: NSTimeInterval) {
        UIView.transitionWithView(self.taskItemBaseView.button,
            duration: ANIMATION_DURATION,
            options: .TransitionCrossDissolve,
            animations: { () -> Void in
                if self.taskItem!.completed {
                    self.taskItemBaseView.button.setImage(UIImage(named: "redo"), forState: UIControlState.Normal)
                } else {
                    self.taskItemBaseView.button.setImage(UIImage(named: "start"), forState: UIControlState.Normal)
                }
            }, completion: nil)
        
    }
    
    // MARK: - TaskRunnerDelegate
    
    func started(sender: TaskRunner!) {
        //self.taskItemBaseView.refreshViewBySeconds(sender.seconds)
        self.taskItemBaseView.switchToBreakButton()
        self.switchViewToRunningState()
        self.switchToRunningPoint()
    }
    
    func refreshViewByState(state: TaskState) {
        self.taskItemBaseView.refreshViewByState(state)

    }
    
    func switchViewToRunningState() {
        self.refreshViewByState(.Running)
    }

    func switchToRunningPoint() {
        UIView.transitionWithView(self.pointImageView,
            duration: ANIMATION_DURATION,
            options: .TransitionCrossDissolve,
            animations: { () -> Void in
                self.pointImageView.image = UIImage(named: "point_green")
            }, completion: nil)
    }
    
    func tick(sender: TaskRunner!) {
//        self.taskItemBaseView.refreshViewBySeconds(sender.seconds)
//        self.taskItemBaseView.switchToBreakButton()
        self.custom_delegate?.tick(self, seconds: sender.seconds)
    }
    
    func completed(sender: TaskRunner!) {
        self.taskItemBaseView.refreshViewByState(.Normal)
        self.custom_delegate?.completed(self)
    }
    
    func breaked(sender: TaskRunner!) {
        self.taskItemBaseView.refreshViewByState(.Normal)
        self.custom_delegate!.breaked(self)
    }
    
    // MARK: - TaskItemBaseViewDelegate
    
    func taskItemBaseView(view: UIView!, buttonClicked sender: UIButton!) {
        
        if !self.taskItem!.completed {
            // This task you haven't completed. you can start it now.
            // But if some other task is running, you can not start it; if the running task is youself, then break youself.
            
            if self.taskRunner!.isRunning {
                // if self.taskRunner!.runningTaskID() == self.taskItem!.taskId {
                if self.taskRunner!.isSameTask(self.taskItem!) {
                    self.breakIt()
                } else {
                    print("You can not start it, some other task is running!")
                }
                return
            }
            
            // No one is running, setup the task item and then you can start now! go go go!
            self.taskRunner!.setupTaskItem(self.taskItem!)
            if self.taskRunner!.canStart() {
                self.custom_delegate?.ready(self)
            }
            
        }
        
        if self.taskItem!.completed {
            // This is completed task, active it.
//            self.taskItem!.completed = false
//            DBOperate.updateTask(self.taskItem!)
            TaskManager.sharedInstance.activeTask(self.taskItem!)
            self.custom_delegate?.activated(self)
            
            if self.taskRunner!.isRunning {
                // Some task is running, you can active it still.
                // but when the task is activeted, the start button must be in the disabled state.
                self.disable(TaskState.Completed, animation: true)
            } else {
                self.disable(TaskState.Normal, animation: true)
            }
        }
    }
    
    func taskItemBaseView(view: UIView, titleLongPressed sender: UILabel) {
        self.custom_delegate?.quickFinish(self)
    }
//    
//    override func layoutSubviews() {
//        self.taskItemBaseView.updateViewsWidth()
//        super.layoutSubviews()
//    }
}
