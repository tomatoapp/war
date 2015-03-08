//
//  Guide5ViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 3/8/15.
//  Copyright (c) 2015 YangCun. All rights reserved.
//

import UIKit

protocol Guide5ViewControllerDelegate {
    func guide5ViewControllerDidClickedFinishedButton(sender: Guide5ViewController)
}

class Guide5ViewController: UIViewController {

    var delegate: Guide5ViewControllerDelegate?
    
    @IBAction func getStartedButtonClicked(sender: AnyObject) {
        println("getStartedButtonClicked")
        self.delegate?.guide5ViewControllerDidClickedFinishedButton(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
