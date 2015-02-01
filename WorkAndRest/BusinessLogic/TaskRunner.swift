//
//  TaskRunner.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/1.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit
import AVFoundation

protocol TaskRunnerDelegate {
    func completed(sender: TaskRunner?)
    func breaked(sender: TaskRunner?)
    func tick(sender: TaskRunner?)
}


class TaskRunner: NSObject, UIAlertViewDelegate {
    
    var delegate: TaskRunnerDelegate?
    var taskItem: Task!
    var isWorking = false
    var secondsLeft = 0
    var timer: NSTimer!
    var minute = 0
    var second = 0
    var seconds = 0
    var secondBeep: AVAudioPlayer!
    var isPlaySecondSound = false

    var timerText: String?
    
    override init() {
        super.init()

        self.seconds = NSUserDefaults.standardUserDefaults().valueForKey(GlobalConstants.k_SECONDS)!.integerValue * 60
        self.isPlaySecondSound = NSUserDefaults.standardUserDefaults().valueForKey(GlobalConstants.kBOOL_SECOND_SOUND)!.boolValue
        self.secondBeep = self.setupAudioPlayerWithFile("sec", type:"wav")
        self.secondsLeft = self.seconds
        self.timerText = self.stringFromSecondsLeft()
        
    }
    
    convenience init(task: Task!) {
        self.init()

        self.taskItem = task
    }
    
    // MARK: - Events
    
     func start() {
        self.isWorking = true
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("tick"), userInfo: nil, repeats: true)
        self.taskItem.completed = false
    }
    
     func stop() {
        self.showStopAlertView()
    }
    
    // MARK: - UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.title == NSLocalizedString("Completed", comment: "") {
            self.reset()
        } else if alertView.title == NSLocalizedString("Break this work?", comment: "") {
            if buttonIndex == 1 {
                self.reset()
                self.delegate?.breaked(self)
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
    
    func stringFromSecondsLeft() -> String {
        self.minute = self.secondsLeft % 3600 / 60
        self.second = self.secondsLeft % 3600 % 60
        return String(format: "00:%02d:%02d", arguments: [self.minute, self.second])
    }
    
    func showStopAlertView() {
        let alert = UIAlertView(title: NSLocalizedString("Break this work?", comment: ""), message: NSLocalizedString("It will be ineffective", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: ""), otherButtonTitles: NSLocalizedString("Yes", comment: ""))
        alert.show()
    }
    
    func tick() {
        
        if self.secondsLeft > 0 {
            self.secondsLeft--
            self.minute = self.secondsLeft % 3600 / 60
            self.second = self.secondsLeft % 3600 % 60
            
            self.timerText = self.stringFromSecondsLeft()
            if self.isPlaySecondSound {
                self.secondBeep.play()
            }
            self.delegate?.tick(self)
            
        } else {
            self.isWorking = false
            self.cancelTimer()
            self.completedOneWorkTime()
            AudioServicesPlaySystemSound(1005)
            let alert = UIAlertView(title: NSLocalizedString("Completed", comment: ""), message: NSLocalizedString("Time is up!", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("YES", comment: ""))
            alert.show()
            
            self.delegate?.completed(self)
        }
    }
    
    func cancelTimer() {
        self.timer.invalidate()
    }
    

    func completedOneWorkTime() {
        self.taskItem.costWorkTimes = self.taskItem.costWorkTimes++
        DBOperate.updateTask(self.taskItem)
        self.timerText = NSString(format: NSLocalizedString("work times: %@", comment: ""), [self.taskItem.costWorkTimes])
    }
    
    func reset() {
        self.cancelTimer()
        self.isWorking = false
        self.secondsLeft = self.seconds
        self.timerText = self.stringFromSecondsLeft()
    }
}