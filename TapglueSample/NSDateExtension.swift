//
//  NSDateExtension.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 27/12/15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import Foundation


extension NSDate {
    
    func toStringFormatHoursMinutes(format: String = "HH:mm") -> String{
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
    
    func toStringFormatDayMonthYear(format: String = "d MMMM y") -> String{
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
    
    func toStringFormatYearMonthDayHoursMinutesSeconds(format: String = "yyyy-MM-dd HH:mm:ss") -> String{
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
}