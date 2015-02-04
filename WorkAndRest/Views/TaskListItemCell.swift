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
    func started(sender: TaskListItemCell!)
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    

    @IBAction func startButtonClicked(sender: AnyObject) {
        
        if self.delegate != nil {
            self.start()
            self.delegate!.started(self)
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
        if self.running {
            return
        }
        self.running = true
        
        println("start() - \(taskItem?.title)" )
        //self.seconds = NSUserDefaults.standardUserDefaults().valueForKey(GlobalConstants.k_SECONDS)!.integerValue * 60 / 15
        self.seconds = self.taskItem!.minutes * 60
        taskRunner = TaskRunner(task: self.taskItem)
        taskRunner?.delegate = self
        taskRunner?.start()
        self.timerLabel.text = self.getTimerString()

        UIView.animateWithDuration(1,
            animations: { () -> Void in
                self.startButton.alpha = 0
                self.timerLabel.alpha = 1
                
            })
            { (finished: Bool) -> Void in
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
    
    func disable() {
        self.reset()
//        self.grayMaskView.alpha = 0.1
        UIView.animateWithDuration(1,
            animations: { () -> Void in
                self.startButton.alpha = 0.5
            })
            { (finished: Bool) -> Void in
                //self.startButton.enabled = false
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
                //self.startButton.enabled = true
        }
        
        UIView.transitionWithView(self.bgImageView,
            duration: 1,
            options: .TransitionCrossDissolve,
            animations: { () -> Void in
                self.bgImageView.image = UIImage(named: "list_item_normal_bg")
                self.pointImageView.image = UIImage(named: "point_yellow")
            })
            { (finished: Bool) -> Void in
        }
    }
    
    func getTimerString() -> String {
        return String(format: "%02d:%02d", arguments: [self.seconds % 3600 / 60, self.seconds % 3600 % 60])
    }
    // MARK: - TaskRunnerDelegate
    
    func tick(sender: TaskRunner?) {
        println("tick" + "\(sender?.taskItem.title)")
        self.seconds = sender!.seconds
        self.timerLabel.text = self.getTimerString()
    }
    
    func completed(sender: TaskRunner?) {
        println("completed")
        let val = AVAudioSession.sharedInstance().outputVolume
        println("outputVolume: \(val)")
        AudioServicesPlaySystemSound(1005)
        self.delegate?.completed(self)
        self.reset()
    }
    
    func breaked(sender: TaskRunner?) {
        
    }
}
