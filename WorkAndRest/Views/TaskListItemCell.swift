//
//  TaskListItemCell.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/30.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit
import AVFoundation

protocol TaskListItemCellDelegate {
    func readyToStart(sender: TaskListItemCell!)
    func tick(timeString: String)
    func completed(sender: TaskListItemCell!)
    func breaked(sender: TaskListItemCell!)
}

class TaskListItemCell: UITableViewCell, TaskRunnerDelegate {

    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bgImageView: UIImageView!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var grayMaskView: UIView!
    @IBOutlet var pointImageView: UIImageView!
    
    var seconds = 0
    var taskItem: Task?
    var taskRunner: TaskRunner?
    var delegate: TaskListItemCellDelegate?
    var running = false
    var state = UITableViewCellStateMask.DefaultMask
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    

    @IBAction func startButtonClicked(sender: AnyObject) {
        
        if self.taskRunner != nil && self.taskRunner!.isWorking {
            self.breakIt()
        } else {
        if self.delegate != nil {
            self.delegate!.readyToStart(self)
            }
        }
    }
    
    func refresh() {
        self.titleLabel.text = taskItem?.title
    }
    
    func setup() {
        self.timerLabel.alpha = 0
        self.grayMaskView.alpha = 0
    }
    
    func start() {
        
        if state != UITableViewCellStateMask.DefaultMask {
            return
        }
        if self.running {
            return
        }
        self.running = true
        
        self.seconds = self.taskItem!.minutes * 60
        
        taskRunner?.start()
        self.timerLabel.text = self.getTimerString()
        UIView.animateWithDuration(1,
            animations: { () -> Void in
                self.startButton.alpha = 0
                self.timerLabel.alpha = 1
            })
            { (finished: Bool) -> Void in
                self.changeToBreakButtonAfter2Seconds()
        }
        
        UIView.transitionWithView(self.bgImageView,
            duration: 1,
            options: .TransitionCrossDissolve,
            animations: { () -> Void in
                self.bgImageView.image = UIImage(named: "list_item_working_bg")
                self.pointImageView.image = UIImage(named: "point_green")
            })
            { (finished: Bool) -> Void in
        }
    }
    
    func breakIt() {
        self.taskRunner!.stop()
    }
    
    func disable() {
        self.reset()
        UIView.animateWithDuration(1,
            animations: { () -> Void in
                self.startButton.alpha = 0.5
            })
            { (finished: Bool) -> Void in
        }
    }
    
    func reset() {
        self.running = false
        UIView.animateWithDuration(1,
            animations: { () -> Void in
                self.timerLabel.alpha = 0
                self.startButton.alpha = 1
                
            })
            { (finished: Bool) -> Void in
        }
        
        UIView.transitionWithView(self.bgImageView,
            duration: 1,
            options: .TransitionCrossDissolve,
            animations: { () -> Void in
                self.bgImageView.image = UIImage(named: "list_item_normal_bg")
            })
            { (finished: Bool) -> Void in
                self.pointImageView.image = UIImage(named: "point_yellow")
                self.startButton.setImage(UIImage(named: "start"), forState: UIControlState.Normal)
        }
    }
    
    func getTimerString() -> String {
        return String(format: "%02d:%02d", arguments: [self.seconds % 3600 / 60, self.seconds % 3600 % 60])
    }
    
    // MARK: - TaskRunnerDelegate
    
    func tick(sender: TaskRunner?) {
        println("tick: " + "\(sender?.taskItem.title)" + "\(sender!.seconds)")
        self.seconds = sender!.seconds
        let result = self.getTimerString()
        self.timerLabel.text = result
        self.delegate?.tick(result)
    }
    
    func completed(sender: TaskRunner?) {
        println("completed")
        AudioServicesPlaySystemSound(1005)
        self.delegate?.completed(self)
        self.reset()
    }
    
    func breaked(sender: TaskRunner?) {
        self.delegate!.breaked(self)
    }
    
    func changeToBreakButtonAfter2Seconds() {
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("changeToBreakButton:"), userInfo: nil, repeats: false)
    }
    
    func changeToBreakButton(sender: NSTimer!) {
        UIView.animateWithDuration(1,
            animations: { () -> Void in
                self.timerLabel.alpha = 0
                self.startButton.alpha = 1
                
            })
            { (finished: Bool) -> Void in
        }
        UIView.transitionWithView(self.startButton,
            duration: 1,
            options: .TransitionCrossDissolve,
            animations: { () -> Void in
                self.startButton.setImage(UIImage(named: "break"), forState: UIControlState.Normal)
            })
            { (finished: Bool) -> Void in
        }
    }
    
    override func willTransitionToState(state: UITableViewCellStateMask) {
        self.state = state
    }
}
