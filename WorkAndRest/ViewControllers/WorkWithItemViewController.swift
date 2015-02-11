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
    var seconds = 0
    var isPlaySecondSound = false
    var secondBeep: AVAudioPlayer!
    var timerText: String?

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
        self.title = self.taskItem.title

        //self.seconds = NSUserDefaults.standardUserDefaults().valueForKey(GlobalConstants.k_SECONDS)!.integerValue * 60
        self.taskRunner = TaskRunner(task: self.taskItem)
        self.taskRunner.delegate = self
        
        self.isPlaySecondSound = NSUserDefaults.standardUserDefaults().valueForKey(GlobalConstants.kBOOL_SECOND_SOUND)!.boolValue
        self.secondBeep = self.setupAudioPlayerWithFile("sec", type:"wav")

        self.soundSwitch.on = self.isPlaySecondSound
        self.soundSwitch.transform = CGAffineTransformMakeScale(0.65, 0.65)
        self.setupMusicalMaskLabel()
        
        self.workTimesLabel.text = NSLocalizedString("work times: %@", comment: "").stringByAppendingString("\(self.taskItem.costWorkTimes)")
        self.timerLabel.text = self.getTimerString()
        
        
        self.reset()
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
        self.showStopAlertView()
    }
    
    @IBAction func silentSwitchValueChanged(sender: AnyObject) {
        self.isPlaySecondSound = !self.isPlaySecondSound
        self.setupMusicalMaskLabel()
        NSUserDefaults.standardUserDefaults().setBool(self.isPlaySecondSound, forKey: GlobalConstants.kBOOL_SECOND_SOUND)
        NSUserDefaults.standardUserDefaults().synchronize()
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
    
    func reset() {
        self.enableButton(self.startButton)
        self.disableButton(self.stopButton)
    }
    
    // MARK: - TaskRunnerDelegate
    
    func started(sender: TaskRunner!) {
        
    }
    func tick(sender: TaskRunner!) {
        self.seconds = sender!.seconds
        self.timerLabel.text = self.getTimerString()
        if self.isPlaySecondSound {
            self.secondBeep.play()
        }
    }
    
    func breaked(sender: TaskRunner!) {
        println("breaked")
        self.reset()
        self.seconds = NSUserDefaults.standardUserDefaults().valueForKey(GlobalConstants.k_SECONDS)!.integerValue * 60
        self.timerLabel.text = self.getTimerString()
    }
    
    func completed(sender: TaskRunner!) {
        println("completed")
        AudioServicesPlaySystemSound(1005)
        let alert = UIAlertView(title: NSLocalizedString("Completed", comment: ""), message: NSLocalizedString("Time is up!", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("YES", comment: ""))
        alert.show()
        self.seconds = NSUserDefaults.standardUserDefaults().valueForKey(GlobalConstants.k_SECONDS)!.integerValue * 60
    }
    
    func setupAudioPlayerWithFile(fileName: String!, type: String!) -> AVAudioPlayer {
        let path = NSBundle.mainBundle().pathForResource(fileName, ofType: type)
        let url = NSURL.fileURLWithPath(path!)
        
        var error: NSError? = nil
        let audioPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
        if audioPlayer == nil {
            println("\(error?.description)")
        }
        return audioPlayer
    }
    
    func getTimerString() -> String {
        return String(format: "00:%02d:%02d", arguments: [self.seconds % 3600 / 60, self.seconds % 3600 % 60])
    }
    
    func setupMusicalMaskLabel() {
        if self.isPlaySecondSound {
            self.musicalNoteLabel.textColor = UIColor(red: 0.0, green: 200.0/255.0, blue: 0, alpha: 1)
        } else {
            self.musicalNoteLabel.textColor = UIColor.grayColor()
        }
    }
    
    func completedOneWorkTime() {
        self.taskItem.costWorkTimes++
        DBOperate.updateTask(self.taskItem)
    }
    
    // MARK: - UIAlertViewDelegate

    func showStopAlertView() {
        let alert = UIAlertView(title: NSLocalizedString("Break this work?", comment: ""), message: NSLocalizedString("It will be ineffective", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: ""), otherButtonTitles: NSLocalizedString("Yes", comment: ""))
        alert.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.title == NSLocalizedString("Completed", comment: "") {
            self.reset()
            self.timerLabel.text = self.getTimerString()
            self.completedOneWorkTime()
            self.workTimesLabel.text = NSLocalizedString("work times: %@", comment: "").stringByAppendingString("\(self.taskItem.costWorkTimes)")
        } else if alertView.title == NSLocalizedString("Break this work?", comment: "") {
            if buttonIndex == 1 {
                self.taskRunner.stop()
            }
        }
    }
}
