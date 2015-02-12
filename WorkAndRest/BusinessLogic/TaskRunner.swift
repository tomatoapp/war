//
//  TaskRunner.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/1.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

enum TaskRunnerState {
    case UnReady, Ready, Running
    
    func description() -> String {
        switch self {
        case .UnReady:
            return "UnReady"
            
        case .Ready:
            return "Ready"
            
        case Running:
            return "Running"
        }
    }
}

protocol TaskRunnerDelegate {
    func started(sender: TaskRunner!)
    func completed(sender: TaskRunner!)
    func breaked(sender: TaskRunner!)
    func tick(sender: TaskRunner!)
}

class TaskRunner: NSObject {
    
    var delegates = [NSObject]()
    var delegate: TaskRunnerDelegate?
    var taskItem: Task!
    var seconds = 0

    //var isReady = false
    var isRunning = false
    var isPause = false
    var timer: NSTimer!
    var state = TaskRunnerState.UnReady
    
    override init() {
        super.init()
    }

    func readyTaskID() -> Int {
        if self.state == TaskRunnerState.Ready {
            return self.taskItem.taskId
        }
        return -1
    }
    
    func runningTaskID() -> Int {
        if self.state == TaskRunnerState.Running {
            return self.taskItem.taskId
        }
        return -1
    }
    
    func isReady() -> Bool {
       return self.taskItem != nil
    }
    
    func addDelegate<T: NSObject where T: TaskRunnerDelegate>(object: T) {
        self.delegates.append(object)
    }
    
    func removeDelegate<T: NSObject where T: TaskRunnerDelegate>(object: T) {
        let index = find(self.delegates, object)
        if index != nil {
            self.delegates.removeAtIndex(index!)
        }
    }
    
    func removeAllDelegate() {
        self.delegates.removeAll(keepCapacity: false)
    }
    
    // MARK: - Methods
    
    func canStart() -> Bool {
        return !self.isRunning && self.isReady()
    }
    
    func setup() {
        self.seconds = self.taskItem.minutes * 10
    }
    
    func setupTaskItem(task: Task) {
        self.taskItem = task
        
        if self.state == TaskRunnerState.Ready {
            println("－－－－－－－－－－－－The state is Ready Now！")
        }
        self.state = TaskRunnerState.Ready
    }
    
     func start() {
        self.setup()
        self.isRunning = true
        self.state = TaskRunnerState.Running
        timer = NSTimer.scheduledTimerWithTimeInterval(3,
            target: self,
            selector: Selector("tick"),
            userInfo: nil,
            repeats: true)
        if self.delegates.count > 0 {
            println("self.delegates.count: \(self.delegates.count)")
            for item in self.delegates {
                if let cell = item as? TaskListItemCell {
                    cell.started(self)
                } else if let vc = item as? TaskDetailsViewController {
                    vc.started(self)
                }
            }
        }
    }
    
     func stop() {
        if self.delegates.count > 0 {
            println("self.delegates.count: \(self.delegates.count)")
            for item in self.delegates {
                if let cell = item as? TaskListItemCell {
                    cell.breaked(self)
                } else if let vc = item as? TaskDetailsViewController {
                    vc.breaked(self)
                }
            }
        }
        self.reset()
    }
    
    func tick() {
        if !self.isPause {
            if self.seconds-- > 0 {
                println("TaskRunner state: \(self.state.description())")
                println("self.delegates.count: \(self.delegates.count)")
                if self.delegates.count > 0 {
                    for item in self.delegates {
                        //println("item: \(item.description)")
                        if let cell = item as? TaskListItemCell {
                            println("item is task list item cell")
                            cell.tick(self)
                        } else if let vc = item as? TaskDetailsViewController {
                            println("item is task details vc")
                            vc.tick(self)
                        }
                    }
                }
            } else {
                self.complete()
            }
        }
    }
    
    func complete() {
        if self.delegates.count > 0 {
            println("self.delegates.count: \(self.delegates.count)")
            for item in self.delegates {
                if let cell = item as? TaskListItemCell {
                    cell.completed(self)
                } else if let vc = item as? TaskDetailsViewController {
                    vc.completed(self)
                }
            }
        }
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
    }
}