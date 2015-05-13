//
//  TaskItemBaseView.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/11.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

enum TaskState {
    case Normal, Running, Completed
}

protocol TaskItemBaseViewDelegate {
    func taskItemBaseView(view: UIView!, buttonClicked sender: UIButton!)
}

class TaskItemBaseView: UIView {
    
    var delegate: TaskItemBaseViewDelegate?
    var ANIMATION_DURATION = 0.5
    var seconds = 0
    var isBreakButtonEnable = true
    var title = ""
    
    @IBOutlet var view: UIView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bgImageView: UIImageView!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var timerLabel: UILabel!
    
    @IBAction func startButtonClicked(sender: AnyObject) {
        self.delegate?.taskItemBaseView(self, buttonClicked: sender as! UIButton)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        NSBundle.mainBundle().loadNibNamed("TaskItemBaseView", owner: self, options: nil)
        self.addSubview(self.view)
        self.timerLabel.alpha = 0
    }
    
    func updateViewsWidth() {
        if self.view.frame.size.width != self.frame.size.width {
            self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.frame.size.width, self.view.frame.size.height)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateViewsWidth()
    }
    
    func refreshTitle(title: String, withTextStrikethrough: Bool = false) {
        self.title = title
        let attributeString = NSMutableAttributedString(string: title)
        attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: withTextStrikethrough ? 1 : 0, range: NSMakeRange(0, attributeString.length))
        self.titleLabel.attributedText = attributeString
    }

    func refreshViewByState(state: TaskState, animation: Bool = true) {
        switch state {
        case .Normal:
            UIView.animateWithDuration(animation ? ANIMATION_DURATION : 0,
                animations: { () -> Void in
                    self.timerLabel.alpha = 0
                    self.startButton.alpha = 1
            })
            
            UIView.transitionWithView(self.bgImageView,
                duration: animation ? ANIMATION_DURATION : 0,
                options: .TransitionCrossDissolve,
                animations: { () -> Void in
                    self.bgImageView.image = UIImage(named: "list_item_normal_bg")
                }, completion: nil)
            UIView.transitionWithView(self.startButton,
                duration: animation ? ANIMATION_DURATION : 0,
                options: .TransitionCrossDissolve,
                animations: { () -> Void in
                    self.startButton.setImage(UIImage(named: "start"), forState: UIControlState.Normal)
                }, completion: nil)
            
            break
            
        case .Running:
            self.timerLabel.text = self.getTimerString()
            UIView.animateWithDuration(animation ? ANIMATION_DURATION : 0,
                animations: { () -> Void in
                    self.timerLabel.alpha = 1
                    self.startButton.alpha = 0
                })
                { (finished: Bool) -> Void in
            }
            
            UIView.transitionWithView(self.bgImageView,
                duration: animation ? ANIMATION_DURATION : 0,
                options: .TransitionCrossDissolve,
                animations: { () -> Void in
                    self.bgImageView.image = UIImage(named: "list_item_working_bg")
                }, completion: nil)
            break
            
        case .Completed:
            UIView.animateWithDuration(animation ? ANIMATION_DURATION : 0,
                animations: { () -> Void in
                    self.timerLabel.alpha = 0
                    self.startButton.alpha = 1
                    self.refreshTitle(self.title, withTextStrikethrough: true)
            })

            self.bgImageView.image = UIImage(named: "list_item_finished_bg")
            UIView.transitionWithView(self.startButton,
                duration: animation ? ANIMATION_DURATION : 0,
                options: .TransitionCrossDissolve,
                animations: { () -> Void in
                    self.startButton.setImage(UIImage(named: "redo"), forState: UIControlState.Normal)
                }, completion: nil)
            break
            
        default:
            break
        }
    }
    
    func refreshViewBySeconds(seconds: Int) {
        self.seconds = seconds
        self.timerLabel.text = self.getTimerString()
    }
    
    func getTimerString() -> String {
        return String(format: "%02d:%02d", arguments: [self.seconds % 3600 / 60, self.seconds % 3600 % 60])
    }
    
    func switchToBreakButton() {
        println("switchToBreakButton")
        UIView.animateWithDuration(ANIMATION_DURATION,
            animations: { () -> Void in
                self.timerLabel.alpha = 0
                self.startButton.alpha = 1
            })
            { (finished: Bool) -> Void in
        }
        UIView.transitionWithView(self.startButton,
            duration: ANIMATION_DURATION,
            options: .TransitionCrossDissolve,
            animations: { () -> Void in
                self.startButton.setImage(UIImage(named: "break"), forState: UIControlState.Normal)
            })
            { (finished: Bool) -> Void in
        }
    }
    
    func disableWithTaskState(state: TaskState, animation: Bool = true) {
        self.refreshViewByState(state)
        
        UIView.animateWithDuration(animation ? ANIMATION_DURATION : 0,
            animations: { () -> Void in
                self.startButton.alpha = 0.5
        })
    }
}
