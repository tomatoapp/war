//
//  TaskDetailsTutorialsViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 3/9/15.
//  Copyright (c) 2015 YangCun. All rights reserved.
//

import UIKit

class TaskDetailsTutorialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func understoodButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
