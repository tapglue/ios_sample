//
//  StringExtension.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 25/07/16.
//  Copyright © 2016 Özgür Celebi. All rights reserved.
//

import Foundation

extension String {

    // If you like to get tags out from a textfield
    func withoutTags(txt: String) -> String{
        let text = txt
        let withoutHashtags = text.componentsSeparatedByString(" ").filter { !$0.containsString("#") }.joinWithSeparator(" ")
        
        return withoutHashtags
    }
    func filterTagsAsStrings(txt: String) -> [String]{
        var wordArr: [String] = []
        var tagArr: [String] = []
        
        let fullText = txt
        wordArr = fullText.componentsSeparatedByString(" ")
        
        for tag in wordArr {
            // Remove hashtag
            if tag.containsString("#") {
                var tempTag = tag
                tempTag.removeAtIndex(tempTag.startIndex)
                
                // Maximum 5 tags are allowed for one Post
                if tagArr.count < 5 {
                    tagArr.append(tempTag)
                }
            }
        }
        
        return tagArr
    }
    
    var capitalizeFirst: String {
        if isEmpty { return "" }
        var result = self
        result.replaceRange(startIndex...startIndex, with: String(self[startIndex]).uppercaseString)
        return result
    }
    
    func toNSDateTime() -> NSDate {
        //Create Date Formatter
        let dateFormatter = NSDateFormatter()
        
        //Specify Format of String to Parse
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        //Parse into NSDate
        let dateFromString: NSDate = dateFormatter.dateFromString(self)!
        
        //Return Parsed Date
        return dateFromString
    }
}

