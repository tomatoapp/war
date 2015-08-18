//
//  TimeSelectorView.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/3.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit
 protocol TimeSelectorViewDelegate {
    func timeSelectorView(selectorView: TimeSelectorView!, didSelectTime minutes:Int)
}

class TimeSelectorView: UIView, V8HorizontalPickerViewDelegate, V8HorizontalPickerViewDataSource {

    // MARK: - Properties
    
    var delegate: TimeSelectorViewDelegate?
    var pickerView: V8HorizontalPickerView?
    var titleArray: [String]!

    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    // MARK: - Methods
    
    func setup() {
        titleArray = ["10:00", "15:00", "20:00", "25:00", "30:00", "35:00", "40:00", "45:00"]

        self.pickerView = V8HorizontalPickerView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        self.pickerView!.backgroundColor = UIColor(red: 187.0/255.0, green: 47.0/255.0, blue: 68.0/255.0, alpha: 1.0)
        self.pickerView!.selectionPoint = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, 0)
        self.pickerView!.selectionIndicatorView = UIImageView(image: UIImage(named: "indicator"))
        self.pickerView!.delegate = self
        self.pickerView!.dataSource = self
        self.pickerView!.scrollToElement(3, animated: false) // Set the default time is 25 minutes
        if self.delegate != nil {
            self.delegate!.timeSelectorView(self, didSelectTime: 25)
        }
        
        
        self.addSubview(pickerView!)

        pickerView!.mas_makeConstraints { make in
            make.width.equalTo()(self.mas_width)
            make.height.equalTo()(self.mas_height)
            make.centerX.equalTo()(self.mas_centerX)
            make.centerY.equalTo()(self.mas_centerY)
            
            return ()
        }
    }
    
    // MARK: - V8HorizontalPickerViewDelegate
    
    func horizontalPickerView(picker: V8HorizontalPickerView!, titleForElementAtIndex index: Int) -> String! {
        return self.titleArray[index]
    }
    
    func horizontalPickerView(picker: V8HorizontalPickerView!, widthForElementAtIndex index: Int) -> Int {
        return Int(49.0 + (UIScreen.mainScreen().bounds.size.width - 49.0 * 3) / 2 - 10.0)
    }
    
    func horizontalPickerView(picker: V8HorizontalPickerView!, didSelectElementAtIndex index: Int) {
        let item = self.titleArray[index]
        let index: String.Index = advance(item.startIndex, 2)
        let result = item.substringToIndex(index)
        let minutes = Int(result)
        if self.delegate != nil {
            self.delegate?.timeSelectorView(self, didSelectTime: minutes!)
        }
    }
    // MARK: - V8HorizontalPickerViewDataSource

    func numberOfElementsInHorizontalPickerView(picker: V8HorizontalPickerView!) -> Int {
        return self.titleArray.count
    }
    
}
