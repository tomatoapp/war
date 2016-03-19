//
//  LogInViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 3/19/16.
//  Copyright © 2016 YangCun. All rights reserved.
//

import UIKit

class LogInViewController: PFLogInViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logoView = UIImageView(image: UIImage(named: "icon"))
        self.logInView?.logo = logoView
        self.logInView?.logo?.sizeToFit()
    }
}
