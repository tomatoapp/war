//
//  RootViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/27.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

class RootViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var titleImageView = UIImageView(image: UIImage(named: "title"))
        self.navigationItem.titleView = titleImageView;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "white"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.translucent = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}