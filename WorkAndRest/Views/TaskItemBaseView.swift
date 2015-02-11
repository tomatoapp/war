//
//  TaskItemBaseView.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/11.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

protocol TaskItemBaseViewDelegate {
    func taskItemBaseView(view: UIView!, buttonClicked sender: UIButton!)
}

class TaskItemBaseView: UIView {

    var delegate: TaskItemBaseViewDelegate?
    
    @IBOutlet var view: UIView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bgImageView: UIImageView!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var timerLabel: UILabel!
    
    @IBAction func startButtonClicked(sender: AnyObject) {
        self.delegate?.taskItemBaseView(self, buttonClicked: sender as UIButton)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    func setup() {
        NSBundle.mainBundle().loadNibNamed("TaskItemBaseView", owner: self, options: nil)
        //self.updateViewsWidth()
        self.addSubview(self.view)
    }
    
    func updateViewsWidth() {
        if self.view.frame.size.width != self.frame.size.width {
            self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.frame.size.width, self.view.frame.size.height)
        }
    }

}
