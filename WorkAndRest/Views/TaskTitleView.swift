//
//  TaskTitleView.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/6.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

protocol TaskTitleViewDelegate {
    func taskTitleView(view: TaskTitleView!, didClickedEditTitleButton sender: UIButton!)
}

class TaskTitleView: UIView {

    var delegate: TaskTitleViewDelegate?
    @IBOutlet var view: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var button: UIButton!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    @IBAction func buttonClick(sender: UIButton!) {
        if self.delegate != nil {
            self.delegate!.taskTitleView(self, didClickedEditTitleButton: sender)
        }
    }
    
    func setTitle(title: String) {
        if title.isEmpty {
            // Hide the label and show the edit task title.
            self.titleLabel.hidden = true
            self.button.setImage(UIImage(named: "edit_task_title"), forState: UIControlState.Normal)
        } else {
            // Show the label and hide the edit task title.
            self.titleLabel.hidden = false
            self.titleLabel.text = title
            self.button.setImage(UIImage(named: ""), forState: UIControlState.Normal)
        }
    }
    
    func setup() {
        NSBundle.mainBundle().loadNibNamed("TaskTitleView", owner: self, options: nil)
        self.addSubview(self.view)
        self.view.mas_updateConstraints { make in
            make.width.equalTo()(self.frame.size.width)
            make.height.equalTo()(self.frame.size.height)
            make.centerX.equalTo()(self.mas_centerX)
            make.centerY.equalTo()(self.mas_centerY)
            return ()
        }
    }

}