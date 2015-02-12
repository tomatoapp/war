//
//  TaskListItemCell.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/30.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

protocol TaskListItemCellDelegate {
    func readyToStart(sender: TaskListItemCell!)
    func tick(sender: TaskListItemCell!, seconds: Int)
    func completed(sender: TaskListItemCell!)
    func breaked(sender: TaskListItemCell!)
    func activated(sender: TaskListItemCell!)
}

class TaskListItemCell: UITableViewCell, TaskRunnerDelegate, TaskItemBaseViewDelegate {
    
    @IBOutlet var tempView: UIView!
    @IBOutlet var taskItemBaseView: TaskItemBaseView!
    @IBOutlet var pointImageView: UIImageView!
    
    var ANIMATION_DURATION = 0.5
    var seconds = 0
    var taskItem: Task?
    var taskRunner: TaskRunner?
    var delegate: TaskListItemCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func refresh() {
        self.taskItemBaseView.refreshTitle(self.taskItem!.title)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
    }
    
    func setup() {
        self.taskItemBaseView.delegate = self
    }
    
    func start() {
        
        if !self.taskRunner!.canStart() {
            println("Can not start!")
            return
        }
        taskRunner?.start()
    }
    
    func breakIt() {
        self.taskRunner!.stop()
    }
    
    func disable() {
        self.taskItemBaseView.disable()
    }
    
    func reset(animation: Bool = true) {
        if self.taskItem!.completed  {
            self.taskItemBaseView.refreshViewByState(TaskState.Completed, animation: animation)
        } else {
            self.taskItemBaseView.refreshViewByState(TaskState.Normal, animation: animation)
        }
        
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
        UIView.transitionWithView(self.taskItemBaseView.startButton,
            duration: ANIMATION_DURATION,
            options: .TransitionCrossDissolve,
            animations: { () -> Void in
                if self.taskItem!.completed {
                    self.taskItemBaseView.startButton.setImage(UIImage(named: "redo"), forState: UIControlState.Normal)
                } else {
                    self.taskItemBaseView.startButton.setImage(UIImage(named: "start"), forState: UIControlState.Normal)
                }
            }, completion: nil)
        
    }
    
    // MARK: - TaskRunnerDelegate
    
    func started(sender: TaskRunner!) {
        self.taskItemBaseView.refreshViewBySeconds(sender.seconds)
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
        self.taskItemBaseView.refreshViewBySeconds(sender.seconds)
        self.delegate?.tick(self, seconds: sender.seconds)
    }
    
    func completed(sender: TaskRunner!) {
        self.taskItemBaseView.refreshViewByState(.Normal)
        self.delegate?.completed(self)
    }
    
    func breaked(sender: TaskRunner!) {
        self.taskItemBaseView.refreshViewByState(.Normal)
        self.delegate!.breaked(self)
    }
    
    // MARK: - TaskItemBaseViewDelegate
    
    func taskItemBaseView(view: UIView!, buttonClicked sender: UIButton!) {
        if self.taskRunner != nil && self.taskRunner!.isRunning {
            if self.taskRunner?.runningTaskID() == self.taskItem?.taskId {
                self.breakIt()
            } else {
                println("Can not start!")
            }
        } else {
            if self.taskItem!.completed {
                self.taskItem!.completed = false
                if DBOperate.updateTask(self.taskItem!) {
                    self.delegate?.activated(self)
                }
            } else {
                self.delegate?.readyToStart(self)
            }
        }
    }
    
    override func layoutSubviews() {
        self.taskItemBaseView.updateViewsWidth()
        super.layoutSubviews()
    }
}
