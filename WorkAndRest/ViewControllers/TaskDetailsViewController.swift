//
//  TaskDetailsViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/10.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

protocol TaskDetailsViewControllerDelegate {
    
}

class TaskDetailsViewController: BaseTableViewController {
    var copyTaskItem: Task!
    var delegate: TaskDetailsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = nil
        self.navigationItem.title = copyTaskItem.title
    }
}
