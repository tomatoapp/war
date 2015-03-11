//
//  WARConfig.swift
//  WorkAndRest
//
//  Created by YangCun on 3/10/15.
//  Copyright (c) 2015 YangCun. All rights reserved.
//

import UIKit

class WARConfig: NSObject {
    class func loadGuideItems() -> Array<Guide> {
        var guides = [Guide]()
        
        var myDict: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("MainConfig", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
            let objects: NSArray = dict.objectForKey("Guide") as NSArray
            for index in 0...objects.count-1 {
                let item: NSDictionary = objects[index] as NSDictionary
                let tempGuide = Guide()
                tempGuide.title = item.valueForKey("title") as String
                tempGuide.subTitle = item.valueForKey("subTitle") as String
                tempGuide.image = item.valueForKey("image") as String
    
                guides.append(tempGuide)
            }
        }
        return guides
    }
}
