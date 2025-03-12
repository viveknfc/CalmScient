//
//  TextHighlighter.swift
//  CalmscientIOS
//
//  Created by NFC User on 12/03/25.
//

import Foundation
import UIKit

class TextHighlighter {
    static func getFormattedText(fullText: String, highlightTexts: [String], highlightColor: UIColor) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: fullText)
        
        for highlightText in highlightTexts {
            let ranges = rangesOf(text: highlightText, in: fullText)
            for range in ranges {
                attributedString.addAttribute(.foregroundColor, value: highlightColor, range: range)
            }
        }
        
        return attributedString
    }
    
    private static func rangesOf(text: String, in fullText: String) -> [NSRange] {
        var ranges: [NSRange] = []
        var searchRange = fullText.startIndex..<fullText.endIndex
        
        while let range = fullText.range(of: text, options: .caseInsensitive, range: searchRange) {
            let nsRange = NSRange(range, in: fullText)
            ranges.append(nsRange)
            
            searchRange = range.upperBound..<fullText.endIndex
        }
        
        return ranges
    }
}
