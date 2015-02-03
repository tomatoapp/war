//
//  TimeSelectorView.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/3.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

class TimeSelectorView: UIPickerView, V8HorizontalPickerViewDelegate, V8HorizontalPickerViewDataSource {

    // MARK: - Properties
    
    @IBOutlet var pickerView: V8HorizontalPickerView!
    var titleArray: [String]!

    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    // MARK: - Methods
    
    func setup() {
        titleArray = ["10:00", "15:00", "20:00", "25:00", "30:00", "35:00", "40:00", "45:00"]
        self.pickerView.selectionPoint = CGPointMake((self.frame.size.width) / 2, 0);
        self.pickerView.selectionIndicatorView = UIImageView(image: UIImage(named: "indicator"))
    }
    
    // MARK: - V8HorizontalPickerViewDelegate
    
    func horizontalPickerView(picker: V8HorizontalPickerView!, titleForElementAtIndex index: Int) -> String! {
        return self.titleArray[index]
    }
    
    func horizontalPickerView(picker: V8HorizontalPickerView!, widthForElementAtIndex index: Int) -> Int {
        return Int(49.0 + (self.frame.size.width - 49.0 * 3) / 2 - 10.0)
    }
    
    func horizontalPickerView(picker: V8HorizontalPickerView!, didSelectElementAtIndex index: Int) {
        
    }
    // MARK: - V8HorizontalPickerViewDataSource

    func numberOfElementsInHorizontalPickerView(picker: V8HorizontalPickerView!) -> Int {
        return self.titleArray.count
    }
    
}
