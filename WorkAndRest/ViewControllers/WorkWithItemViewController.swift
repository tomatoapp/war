//
//  WorkWithItemViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/30.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit
import AVFoundation

class WorkWithItemViewController: BaseViewController, UIAlertViewDelegate, TaskRunnerDelegate {

    var taskRunner: TaskRunner!
    var taskItem: Task!
    var isPlaySecondSound = false

    // MARK: - Properties
    
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var workTimesLabel: UILabel!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    //@IBOutlet var silentButton: UIButton!
    @IBOutlet var soundSwitch: UISwitch!
    
    @IBOutlet var musicalNoteLabel: UILabel!
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.taskRunner = TaskRunner(task: self.taskItem)
        self.taskRunner.delegate = self
        
        self.title = self.taskItem.title
        self.workTimesLabel.text = NSLocalizedString("work times: %@", comment: "").stringByAppendingString("\(self.taskItem.costWorkTimes)")
        self.isPlaySecondSound = NSUserDefaults.standardUserDefaults().valueForKey(GlobalConstants.kBOOL_SECOND_SOUND)!.boolValue

        self.soundSwitch.on = self.isPlaySecondSound
        self.soundSwitch.transform = CGAffineTransformMakeScale(0.65, 0.65)
        
        self.enableButton(self.startButton)
        self.disableButton(self.stopButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Events
    
    @IBAction func start() {
        taskRunner.start()
        self.enableButton(self.stopButton)
        self.disableButton(self.startButton)
 
    }
    
    @IBAction func stop() {
        taskRunner.stop()
    }
    
    @IBAction func silentSwitchValueChanged(sender: AnyObject) {
        //NSUserDefaults.standardUserDefaults().setBool(self.isPlaySecondSound, forKey: GlobalConstants.kBOOL_SECOND_SOUND)
    }

    func enableButton(button: UIButton!) {
        button.enabled = true
        if button == self.startButton {
            let color = UIColor(red: 0, green: 200.0/255.0, blue: 0, alpha: 1)
            button.layer.borderColor = color.CGColor
            button.titleLabel?.textColor = color
            button.setTitleColor(color, forState: UIControlState.Normal)
        } else if button == self.stopButton {
            button.layer.borderColor = UIColor.redColor().CGColor
            button.titleLabel?.textColor = UIColor.redColor()
            button.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        }
    }
    
    func disableButton(button: UIButton!) {
        button.enabled = false
        button.layer.borderColor = UIColor.grayColor().CGColor
        button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
    }
    
    // MARK: - TaskRunnerDelegate
    
    func tick(sender: TaskRunner?) {
        self.timerLabel.text = sender?.timerText
    }
    
    func breaked(sender: TaskRunner?) {
        println("breaked")
    }
    
    func completed(sender: TaskRunner?) {
        println("completed")
    }
    
}
