//
//  TaskItemBaseView.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/11.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit
import AVFoundation

enum TaskState {
    case Normal, Running, Completed
}

protocol TaskItemBaseViewDelegate {
    func taskItemBaseView(view: UIView!, buttonClicked sender: UIButton!)
    func taskItemBaseView(view: UIView, titleLongPressed sender: UILabel)
}

class TaskItemBaseView: UIView {
    
    var delegate: TaskItemBaseViewDelegate?
    var ANIMATION_DURATION = 0.3
    var seconds = 0
    var isBreakButtonEnable = true
    var title = ""
    
    @IBOutlet var view: UIView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bgImageView: UIImageView!
    @IBOutlet var button: UIButton!
    @IBOutlet var timerLabel: UILabel!
    
    @IBAction func startButtonClicked(sender: AnyObject) {
        self.delegate?.taskItemBaseView(self, buttonClicked: sender as! UIButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
        self.setupLongPress()
    }
    
    func setupLongPress() {
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "longPress:")
        let tempButton = UIButton(frame: self.titleLabel.frame)
        self.addSubview(tempButton)
        tempButton.addGestureRecognizer(longPress)
    }
    
    func longPress(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            AudioServicesPlaySystemSound(1114)
        }
        if sender.state == .Ended {
            self.delegate?.taskItemBaseView(self, titleLongPressed: self.titleLabel)
        }
    }
    
    func setup() {
        NSBundle.mainBundle().loadNibNamed("TaskItemBaseView", owner: self, options: nil)
        self.addSubview(self.view)
//        self.timerLabel.alpha = 0
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

    func refreshCompletedCount(count: Int) {
        if count > 0 {
            self.timerLabel.text = "🍅×\(count)"
        } else {
            self.timerLabel.text = ""
        }
    }
    
    func refreshViewByState(state: TaskState, animation: Bool = true) {
        switch state {
        case .Normal:
            UIView.animateWithDuration(animation ? ANIMATION_DURATION : 0,
                animations: { () -> Void in
//                    self.timerLabel.alpha = 0
                    self.button.alpha = 1
            })
            
            UIView.transitionWithView(self.bgImageView,
                duration: animation ? ANIMATION_DURATION : 0,
                options: .TransitionCrossDissolve,
                animations: { () -> Void in
                    self.bgImageView.image = UIImage(named: "list_item_normal_bg")
                }, completion: nil)
            UIView.transitionWithView(self.button,
                duration: animation ? ANIMATION_DURATION : 0,
                options: .TransitionCrossDissolve,
                animations: { () -> Void in
                    self.button.setImage(UIImage(named: "start"), forState: UIControlState.Normal)
                }, completion: nil)
            
            break
            
        case .Running:
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
//                    self.timerLabel.alpha = 0
                    self.button.alpha = 1
                    self.refreshTitle(self.title, withTextStrikethrough: true)
            })

            self.bgImageView.image = UIImage(named: "list_item_finished_bg")
            UIView.transitionWithView(self.button,
                duration: animation ? ANIMATION_DURATION : 0,
                options: .TransitionCrossDissolve,
                animations: { () -> Void in
                    self.button.setImage(UIImage(named: "redo"), forState: UIControlState.Normal)
                }, completion: nil)
            break
        }
    }
    
//    func refreshViewBySeconds(seconds: Int) {
//        self.seconds = seconds
//        self.timerLabel.text = self.getTimerString()
//    }
    
//    func getTimerString() -> String {
//        return String(format: "%02d:%02d", arguments: [self.seconds % 3600 / 60, self.seconds % 3600 % 60])
//    }
    
    func switchToBreakButton() {
        print("switchToBreakButton")
        UIView.animateWithDuration(ANIMATION_DURATION,
            animations: { () -> Void in
//                self.timerLabel.alpha = 0
                self.button.alpha = 1
            })
            { (finished: Bool) -> Void in
        }
        UIView.transitionWithView(self.button,
            duration: ANIMATION_DURATION,
            options: .TransitionCrossDissolve,
            animations: { () -> Void in
                self.button.setImage(UIImage(named: "break"), forState: UIControlState.Normal)
            })
            { (finished: Bool) -> Void in
        }
    }
    
    func disableWithTaskState(state: TaskState, animation: Bool = true) {
        self.refreshViewByState(state)
        
        UIView.animateWithDuration(animation ? ANIMATION_DURATION : 0,
            animations: { () -> Void in
                self.button.alpha = 0.5
        })
    }
}
