//
//  QuotationManager.swift
//  WorkAndRest
//
//  Created by YangCun on 7/28/15.
//  Copyright (c) 2015 YangCun. All rights reserved.
//

import UIKit

enum LanguageType {
    case cn
    case en
}
class QuotationManager: NSObject {
    func getQuotation() -> String? {
        return self.getRandomQuotation()
    }
    
    func getRandomQuotation() -> String? {
        var quotation: String? = nil
        while quotation == nil {
            let randomNumber = Int(arc4random_uniform(228))// return 0 ~ n-1
            quotation = self.getQuotationByIndex(randomNumber)
        }
        return quotation
    }
    
    func getQuotationByIndex(index: Int) -> String? {
        let quotations = self.loadQuotations() as! [String]
        if index < quotations.count {
            return quotations[index]
        }
        return nil
    }
    
    func loadQuotations() -> NSArray? {
        let language: AnyObject = NSLocale.preferredLanguages()[0]
        if language as! String == "zh-Hans" {
            return self.loadQuotationsByLanguage(.cn)
        } else {
            return self.loadQuotationsByLanguage(.en)
        }
    }
    
    func loadQuotationsByLanguage(language: LanguageType) -> NSArray? {
        let flag = language == LanguageType.cn ? "cn" : "en"
        let plistPath = NSBundle.mainBundle().pathForResource("Quotations-\(flag)", ofType: "plist")
        let dictionary = NSDictionary(contentsOfFile: plistPath!)
        let array = NSArray(contentsOfFile: plistPath!)
        return array
    }
    
}
