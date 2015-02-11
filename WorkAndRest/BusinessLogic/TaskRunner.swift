//
//  TaskRunner.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/1.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

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

    var isReady = false
    var isRunning = false
    var isPause = false
    var timer: NSTimer!
    
    override init() {
        super.init()
    }
    
    convenience init(task: Task!) {
        self.init()
        self.taskItem = task
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
        return !self.isRunning && self.isReady && self.taskItem != nil
    }
    
    func setup() {
        self.seconds = self.taskItem.minutes * 10
    }
    
     func start() {
        self.setup()
        self.isRunning = true
        timer = NSTimer.scheduledTimerWithTimeInterval(1,
            target: self,
            selector: Selector("tick"),
            userInfo: nil,
            repeats: true)
        if self.delegates.count > 0 {
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
        self.reset()
        if self.delegates.count > 0 {
            for item in self.delegates {
                if let cell = item as? TaskListItemCell {
                    cell.breaked(self)
                } else if let vc = item as? TaskDetailsViewController {
                    vc.breaked(self)
                }
            }
        }
    }
    
    func tick() {
        if !self.isPause {
            if self.seconds-- > 0 {
                //println("TaskRunner: \(self.seconds)")
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
        self.reset()
        if self.delegates.count > 0 {
            for item in self.delegates {
                if let cell = item as? TaskListItemCell {
                    cell.completed(self)
                } else if let vc = item as? TaskDetailsViewController {
                    vc.completed(self)
                }
            }
        }
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
    }
}