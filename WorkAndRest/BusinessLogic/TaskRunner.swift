//
//  TaskRunner.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/1.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit
import AVFoundation

enum TaskRunnerState {
    case UnReady, Ready, Running
}

protocol TaskRunnerDelegate {
    func started(sender: TaskRunner!)
    func completed(sender: TaskRunner!)
    func breaked(sender: TaskRunner!)
    func tick(sender: TaskRunner!)
}

private let singleInstance = TaskRunner()
class TaskRunner: NSObject {
    
    var delegate: TaskRunnerDelegate?
    var taskItem: Task!
    var seconds = 0

    var isRunning = false
    var isPause = false
    var timer: NSTimer!
    var state = TaskRunnerState.UnReady
    
    class var sharedInstance: TaskRunner {
        return singleInstance
    }
    
    override init() {
        super.init()
    }

//    func readyTaskID() -> Int {
//        if self.state == TaskRunnerState.Ready {
//            return self.taskItem.taskId
//        }
//        return -1
//    }
//    
//    func runningTaskID() -> Int {
//        if self.state == TaskRunnerState.Running {
//            return self.taskItem.taskId
//        }
//        return -1
//    }
    
    func isReady() -> Bool {
       return self.taskItem != nil
    }

    // MARK: - Methods
    
    func canStart() -> Bool {
        return !self.isRunning && self.isReady() && !self.taskItem.completed
    }
    
    func setupTaskItem(task: Task) {
        self.taskItem = task
        self.seconds = 1// task.minutes * 60
        self.state = TaskRunnerState.Ready
    }
    
     func start() {
        self.isRunning = true
        self.state = TaskRunnerState.Running
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0,
            target: self,
            selector: Selector("tick"),
            userInfo: nil,
            repeats: true)
        self.delegate?.started(self)
    }
    
     func stop() {
        self.delegate?.breaked(self)
        self.reset()
    }
    
    func tick() {
        if !self.isPause {
            if self.seconds-- > 0 {
                self.delegate?.tick(self)
            } else {
                self.complete()
            }
        }
    }
    
    func complete() {
        AudioServicesPlaySystemSound(1005)
        self.delegate?.completed(self)
        self.reset()
    }
    
    func pause() {
        self.isPause = true
    }
    
    func resume() {
        self.isPause = false
    }
    func cancel() {
        self.timer.invalidate()
    }
    
    func reset() {
        self.cancel()
        self.isRunning = false
        self.state = TaskRunnerState.UnReady
        self.taskItem = nil
        self.seconds = 0
    }
    
    func isSameTask(task: Task) -> Bool {
        return self.taskItem.taskId == task.taskId
    }
}