//
//  MentionParser.swift
//  Mentions
//
//  Created by magicmon on 2017. 3. 28..
//
//
import UIKit

public enum ParserPattern: String {
    case mention = "\\[([\\w\\d\\sㄱ-ㅎㅏ-ㅣ가-힣.]{1,})\\]"
    case html = "\\[\\b(https?://[\\w\\d-]+(\\.[\\w\\d-]+)*\\.[\\w\\d]{2,}(?:/[\\w\\d-./?%&=]*)?)\\b\\]"
    case custom = "@((?!@).)*"
}

extension UIView {
    func parse(_ text: String?, pattern: ParserPattern, template: String, prefixMention: String = "@") -> (String?, [(String, NSRange)]?) {
        guard var matchText = text else {
            return (nil, nil)
        }
        
        var matchUsers: [(String, NSRange)] = []
        
        while true {
            guard let match = matchText.getFirstElements(pattern) else {
                break
            }
            
            let firstFindedText = matchText.substringFromNSRange(match.range)
            
            let data = firstFindedText.replacingOccurrences(of: pattern.rawValue, with: template, options: .regularExpression, range: firstFindedText.range(of: firstFindedText))
            
            if data.count > 0 {
                matchText = matchText.replacing(pattern: pattern, range: match.range, withTemplate: "\(prefixMention)\(template)")
                
                let matchRange = NSRange(location: match.range.location, length: data.utf16.count + prefixMention.utf16.count)
                matchText = matchText.replacing("\(prefixMention)\(data)", range: matchRange)
                
                matchUsers.append((data, matchRange))
            }
        }
        
        // replacing
        matchText = matchText.replacingOccurrences(of: "\\[", with: "[")
        matchText = matchText.replacingOccurrences(of: "\\]", with: "]")
        matchText = matchText.replacingOccurrences(of: "\\\\", with: "\\")
        
        
        if matchUsers.count > 0 {
            return (matchText, matchUsers)
        }
        
        return (matchText, nil)
    }
}


// MARK: - Element
extension String {
    func getElements(_ pattern: ParserPattern = .mention) -> [NSTextCheckingResult] {
        guard let elementRegex = try? NSRegularExpression(pattern: pattern.rawValue, options: [.caseInsensitive]) else {
            return []
        }
        
        return elementRegex.matches(in: self, options: [], range: NSRange(0..<self.utf16.count))
    }
    
    func getFirstElements(_ pattern: ParserPattern = .mention) -> NSTextCheckingResult? {
        guard let elementRegex = try? NSRegularExpression(pattern: pattern.rawValue, options: [.caseInsensitive]) else {
            return nil
        }
        
        return elementRegex.firstMatch(in: self, options: [], range: NSRange(0..<self.utf16.count))
    }
    
    func replacing(pattern: ParserPattern = .mention, range: NSRange? = nil, withTemplate: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern.rawValue, options: [.caseInsensitive]) else {
            return self
        }
        
        if let range = range {
            return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: withTemplate)
        } else {
            return regex.stringByReplacingMatches(in: self, options: [], range: NSRange(0..<self.utf16.count), withTemplate: withTemplate)
        }
    }
    
    func replacing(_ withString: String, range: NSRange) -> String {
        if let textRange = self.rangeFromNSRange(range) {
            return self.replacingCharacters(in: textRange, with: withString)
        }
        
        return self
    }
}
