//
//  ExplainTomatoTimeViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 7/23/15.
//  Copyright (c) 2015 YangCun. All rights reserved.
//

import UIKit

class ExplainTomatoTimeViewController: BaseTranslucentViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.setTransitionMode(TransitionMode.None)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func closeButtonClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
