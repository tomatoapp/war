//
//  InterfaceController.swift
//  WorkAndRest WatchKit Extension
//
//  Created by Carl.Yang on 6/17/15.
//  Copyright (c) 2015 YangCun. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    let mmwornhole = MMWormhole(applicationGroupIdentifier: IdentifierDef.AppGroupIdentifier, optionalDirectory: nil)
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func buttonClicked() {
         self.mmwornhole.passMessageObject(nil, identifier: IdentifierDef.TestIdentifier)
    }
}
