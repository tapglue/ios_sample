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
    
    func toTimeFormatInElapsedTimeToString() -> String {
        // Get the time of event creation
        let elapsedTime = NSDate().timeIntervalSinceDate(self)
        // Save elapsedTime as Int
        let duration = Int(elapsedTime)
        
        // Handle Int duration
        let seconds = duration % 60
        let minutes = (duration / 60) % 60
        let hours = duration / 3600
        let days = duration / 86400
        let weeks = duration / 604800
        let strWeeks = days > 9 ? String(weeks) : "" + String(weeks)
        let strDays = days > 9 ? String(days) : "" + String(days)
        let strHours = hours > 9 ? String(hours) : "" + String(hours)
        let strMinutes = minutes > 9 ? String(minutes) : "" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds) : "" + String(seconds)
        
        if weeks > 1 {
            return "\(strWeeks) weeks"
        }
        else if weeks == 1 {
            return "\(strWeeks) week"
        }
        else if days > 1 {
            return "\(strDays) days"
        }
        else if days == 1
        {
            return "yesterday"
        }
        else if hours > 1 {
            return "\(strHours) hrs"
        }
        else if hours == 1
        {
            return "\(strHours) hrs"
        }
        else if minutes > 1
        {
            return "\(strMinutes) min"
        }
        else if minutes == 1
        {
            return "\(strMinutes) min"
        }
        else if seconds > 1
        {
            return "\(strSeconds) sec"
        }
        else
        {
            return "\(strSeconds) sec"
        }
    }
}