//
//  WARProgressHUD.swift
//  WorkAndRest
//
//  Created by YangCun on 3/7/15.
//  Copyright (c) 2015 YangCun. All rights reserved.
//

import UIKit

class WARProgressHUD: NSObject {
   
    var _progressHUD: MBProgressHUD
    
    class var progressHUD: MBProgressHUD {
        return _progressHUD
    }
    override init() {
//        progressHUD = MBProgressHUD(window: UIApplication.sharedApplication().delegate?.window!)
        
        super.init()

    }
    class func show() {
        
    }
    
    class func dismiss() {
    
    }
}
