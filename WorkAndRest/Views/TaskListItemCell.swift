//
//  TaskListItemCell.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/30.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

protocol TaskListItemCellDelegate {
    func start(cell: TaskListItemCell!, item: Task!)
}

class TaskListItemCell: UITableViewCell {

    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bgImageView: UIImageView!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var grayMaskView: UIView!
    
    var taskItem: Task?
    var delegate: TaskListItemCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    

    @IBAction func startButtonClicked(sender: AnyObject) {
        
        if self.delegate != nil {
            self.delegate!.start(self, item: taskItem)
        }
        
        
    }
    
    func refresh() {
        self.titleLabel.text = taskItem?.title
        //self.setup()
    }
    
    func setup() {
        self.timeLabel.alpha = 0
        self.grayMaskView.alpha = 0
    }
    
    func start() {
        println("start() - \(taskItem?.title)" )
        UIView.animateWithDuration(1,
            animations: { () -> Void in
                self.startButton.alpha = 0
                self.timeLabel.alpha = 1
            })
            { (finished: Bool) -> Void in
        }
        
        UIView.transitionWithView(self.bgImageView,
            duration: 1,
            options: .TransitionCrossDissolve,
            animations: { () -> Void in
                self.bgImageView.image = UIImage(named: "list_item_working_bg")
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
        UIView.animateWithDuration(1,
            animations: { () -> Void in
                self.timeLabel.alpha = 0
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
            })
            { (finished: Bool) -> Void in
        }
    }
}
