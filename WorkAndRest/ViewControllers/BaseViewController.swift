//
//  BaseViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/30.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.titleView = UIImageView(image: UIImage(named: "title"))
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "white"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.translucent = false
          self.navigationController?.navigationBar.tintColor = UIColor(red: 65/255, green: 117/255, blue: 5/255, alpha: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}
