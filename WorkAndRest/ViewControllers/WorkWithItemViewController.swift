//
//  WorkWithItemViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/30.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit
import AVFoundation

class WorkWithItemViewController: BaseViewController, UIAlertViewDelegate {

    var itemToWork: Task!
    var isWorking = false
    var secondsLeft = 0
    
    var timer: NSTimer!
    var minute = 0
    var second = 0
    var seconds = 0
    var secondBeep: AVAudioPlayer!
    var isPlaySecondSound = false
    var isKeepScreenLight = false
    
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var workTimesLabel: UILabel!
    @IBOutlet var silentButton: UIButton!
    
    @IBAction func start() {
        self.isWorking = true
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("subtractTime"), userInfo: nil, repeats: true)
        self.itemToWork.completed = false
        self.enableButton(self.stopButton)
        self.enableButton(self.silentButton)
        self.disableButton(self.startButton)
        
        if self.isKeepScreenLight {
            UIApplication.sharedApplication().idleTimerDisabled = true
        }
    }
    
    @IBAction func stop() {
        self.showStopAlertView()
    }
    
    @IBAction func silentButtonClick(sender: UIButton!) {
        self.isPlaySecondSound = !self.isPlaySecondSound
        if self.isPlaySecondSound {
            self.silentButton.setTitleColor(UIColor(red: 0, green: 200.0/255.0, blue: 0, alpha: 1), forState: UIControlState.Normal)
        } else {
            self.silentButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        }
        NSUserDefaults.standardUserDefaults().setValue(self.isPlaySecondSound, forKey: "SecondSound")
    }
    
    
    func completedOneWorkTime() {
        self.itemToWork.costWorkTimes = self.itemToWork.costWorkTimes++
        DBOperate .updateTask(self.itemToWork)
        self.workTimesLabel.text = NSString(format: NSLocalizedString("work times: %@", comment: ""), [self.itemToWork.costWorkTimes])
    }
    
    func reset() {
        self.cancelTimer()
        self.resetTimerLabel()
        self.isWorking = false
        
        self.enableButton(self.startButton)
        self.disableButton(self.startButton)
        self.disableButton(self.silentButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.seconds = NSUserDefaults.standardUserDefaults().valueForKey("Seconds")!.integerValue * 60
        isPlaySecondSound = NSUserDefaults.standardUserDefaults().valueForKey("SecondSound")!.boolValue
        isKeepScreenLight = NSUserDefaults.standardUserDefaults().valueForKey("KeepLight")!.boolValue
        self.setupAudioPlayerWithFile("sec", type:"wav")
        self.title = self.itemToWork.title
        self.secondsLeft = self.seconds
        self.timerLabel.text = self.stringFromSecondsLeft(self.secondsLeft)
        self.workTimesLabel.text = NSString(format: NSLocalizedString("work times: %@", comment: ""), [self.itemToWork.costWorkTimes])
        self.enableButton(self.startButton)
        self.disableButton(self.stopButton)
        self.disableButton(self.silentButton)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isWorking {
            self.cancelTimer()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.title == NSLocalizedString("Completed", comment: "") {
            self.resetTimerLabel()
        } else if alertView.title == NSLocalizedString("Break this work?", comment: "") {
            if buttonIndex == 1 {
                self.isWorking = false
                self.cancelTimer()
                self.resetTimerLabel()
                self.enableButton(self.startButton)
                self.disableButton(self.stopButton)
                self.disableButton(self.silentButton)
            }
        }
    }

    // MARK: - Private Methods
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

    func stringFromSecondsLeft(theSeconds: Int) -> String {
        minute = theSeconds % 3600 / 60
        second = theSeconds % 3600 % 60
        return NSString(format: "00:%02d:%02d", [minute, second])
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
        } else {
            if self.isPlaySecondSound {
                self.silentButton.setTitleColor(UIColor(red: 0, green: 200.0/255.0, blue: 0, alpha: 1), forState: UIControlState.Normal)
            } else {
                self.silentButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            }
        }
    }
    
    func disableButton(button: UIButton!) {
        button.enabled = false
        button.layer.borderColor = UIColor.grayColor().CGColor
        button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
    }
    
    func showStopAlertView() {
        let alert = UIAlertView(title: NSLocalizedString("Break this work?", comment: ""), message: NSLocalizedString("It will be ineffective", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: ""), otherButtonTitles: NSLocalizedString("Yes", comment: ""))
        alert.show()
    }
    
    func subtractTime() {
        if self.secondsLeft > 0 {
            self.secondsLeft--
            self.minute = self.secondsLeft % 3600 / 60
            self.second = self.secondsLeft % 3600 % 60
            
            self.timerLabel.text = self.stringFromSecondsLeft(self.secondsLeft)
            if self.isPlaySecondSound {
                secondBeep.play()
            }
        } else {
            self.isWorking = false
            self.cancelTimer()
            self.completedOneWorkTime()
            AudioServicesPlaySystemSound(1005)
            let alert = UIAlertView(title: NSLocalizedString("Completed", comment: ""), message: NSLocalizedString("Time is up!", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("YES", comment: ""))
            alert.show()
            
            self.disableButton(self.stopButton)
            self.disableButton(self.silentButton)
            self.enableButton(self.startButton)
        }
    }
    
    func cancelTimer() {
        self.timer.invalidate()
    }
    
    func resetTimerLabel() {
        self.secondsLeft = self.seconds
    }
}
