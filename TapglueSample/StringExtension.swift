//
//  StringExtension.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 25/07/16.
//  Copyright © 2016 Özgür Celebi. All rights reserved.
//

import Foundation

extension String {

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
}