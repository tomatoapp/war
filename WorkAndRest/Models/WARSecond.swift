//
//  WARSecond.swift
//  WorkAndRest
//
//  Created by Carl.Yang on 8/7/15.
//  Copyright (c) 2015 YangCun. All rights reserved.
//

import UIKit

class WARSecond {
    var second: Int = 0
//    init(_ str: String)
    init(_ i: Int) {
        self.second = i
    }
    
    class func zero() -> WARSecond {
        return WARSecond(0)
    }
    
    func timeString() -> String {
        return String(format: "%02d:%02d", arguments: [self.second % 3600 / 60, self.second % 3600 % 60])
    }
}
func - (left: WARSecond, right: Int) -> WARSecond {
    left.second -= right
    return left
}

func == (left: WARSecond, right: WARSecond) -> Bool{
    return left.second == right.second
}

func -= (left: WARSecond, right: Int) -> WARSecond {
    left.second -= right
    return left
}

postfix func -- (left: WARSecond) -> WARSecond {
    left.second--
    return left
}

