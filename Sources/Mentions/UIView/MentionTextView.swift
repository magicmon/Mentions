//
//  MentionTextView.swift
//  Mentions
//
//  Created by magicmon on 2017. 3. 28..
//
//

import UIKit

public enum MentionDeleteType {
    case cancel  // cancel mention(changed text)
    case delete  // delete mention
}

public class MentionTextView: UITextView {
    
    @IBInspectable public var highlightColor: UIColor = UIColor.blue
    
    var replaceValues: (oldText: String?, range: NSRange?, replacementText: String?) = (nil, nil, nil)
    
    var highlightUsers: [(String, NSRange)] = []        // list for mention user
    
    public var deleteType: MentionDeleteType = .cancel
    
    public var mentionText: String? {
        var replaceText = self.text
        replaceText = replaceText?.replacingOccurrences(of: "\\", with: "\\\\")
        replaceText = replaceText?.replacingOccurrences(of: "[", with: "\\[")
        replaceText = replaceText?.replacingOccurrences(of: "]", with: "\\]")
        
        if highlightUsers.count > 0 {
            for maps in highlightUsers.reversed() {
                replaceText = replaceText?.replacing("[\(maps.0)]", range: maps.1)
            }
            
            return replaceText
        }
        
        return replaceText
    }
    
    // MARK: override
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        delegate = self
    }
}

// MARK: - Highlight
extension MentionTextView {
    public func setMentionText(_ text: String?, pattern: ParserPattern = .mention, prefixMention: String = "@") {
        let (matchText, matchUsers) = self.parse(text, pattern: pattern, template: "$1", prefixMention: prefixMention)
        
        self.text = matchText
        
        if let matchUsers = matchUsers {
            highlightUsers.removeAll()
            for (user, range) in matchUsers {
                highlightUsers.append((user, range))
            }
            
            refresh()
        }
    }
    
    public func insert(to user: String?, with nsrange: NSRange? = nil, prefixMention: String = "@") {
        guard let user = user else { return }
        
        guard user.utf16.count > 0 else { return }
        
        var nsrange = nsrange ?? self.selectedRange
        
        // 추가하려는 텍스트의 range 위치 셋팅. 범위가 넘어가면 해당 범위까지만 셋팅.
        var rangeLength = nsrange.length
        if nsrange.location + nsrange.length > text.utf16.count {
            rangeLength = nsrange.length - (nsrange.location + nsrange.length - text.utf16.count)
        }
        nsrange = NSRange.init(location: min(text.utf16.count, nsrange.location), length: rangeLength)
        guard let range = self.text.rangeFromNSRange(nsrange) else {
            return
        }
        
        // 변환 값 셋팅
        replaceValues = (text, nsrange, "\(prefixMention)\(user)")
        
        // 변환된 맨션을 텍스트뷰에 추가
        
        // 텍스트 수정(맨션 문자 + 닉네임)
        self.text = self.text.replacingCharacters(in: range, with: "\(prefixMention)\(user)")
        
        // 맨션 위치 재 정렬
        self.textViewDidChange(self)
        
        // 리스트에 맨션 영역 추가
        let insertRange = NSRange.init(location: nsrange.location, length: user.utf16.count + prefixMention.utf16.count)
        highlightUsers.append((user, insertRange))
        
        // range 정렬(location 순으로 오름차순)
        highlightUsers.sort(by: { (lhs, rhs) -> Bool in
            return lhs.1.location < rhs.1.location
        })
        
        // 맨션 끝으로 커서 이동
        self.selectedRange = NSMakeRange(insertRange.location + insertRange.length, 0)
        
        refresh()
    }
    
    func refresh() {
        // get current cursor position
        let selectedRange = self.selectedRange
        
        // set attributed text
        let attributedText = NSMutableAttributedString()
        attributedText.appendText(text, font: self.font!, color: UIColor.black)
        
        for range in highlightUsers {
            if range.1.length + range.1.location <= text.utf16.count {
                attributedText.addAttributes(self.font!, color: highlightColor, range: range.1)
            }
        }
        
        self.attributedText = attributedText
        
        // set cursor position
        self.selectedRange = selectedRange
    }
}

extension MentionTextView: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        replaceValues = (textView.text, range, text)
        return true
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        defer {
            replaceValues = (nil, nil, nil)
            refresh()
        }
        
        guard let range = replaceValues.range else {
            return
        }
        
        guard let replacementText = replaceValues.replacementText else {
            return
        }
        
        if replacementText.utf16.count > 0 {
            // insert Text
            
            // If the length does not change even after adding text
            // (If you add neutral or vertical, it is entered, but it does not actually affect the overall length)
            if replaceValues.oldText?.utf16.count == textView.text.utf16.count && range.length == 0 {
                return
            }
            
            var newUsers: [(String, NSRange)] = []
            for oldUser in highlightUsers {
                
                // 추가하는 영역이 내 맨션을 포함하는 경우
                if range.location < oldUser.1.location + oldUser.1.length && range.location + range.length > oldUser.1.location {
                    continue
                } else {
                    // 내 영역을 포함하지 않음
                    
                    // 내 앞쪽에서 시작해서 앞쪽에서 끝나는지
                    if range.location + range.length <= oldUser.1.location {
                        let newRange = NSRange.init(location: max(0, oldUser.1.location + (replacementText.utf16.count - range.length)), length: oldUser.1.length)
                        newUsers.append((oldUser.0, newRange))
                    } else {
                        // 내 뒤쪽에서 시작해서 뒤쪽에서 끝나는지
                        newUsers.append(oldUser)
                    }
                }
            }
            
            highlightUsers = newUsers
        } else {
            // remove Text
            
            // If the length remains unchanged even after erasing
            // (Even if you delete a neutral or a species, it doesn't actually delete them.) << only unicode case.
            if replaceValues.oldText?.utf16.count == textView.text.utf16.count {
                return
            }
            
            // Check whether a mention is included while deleting text.
            // If my mention is included, remove the mention
            // otherwise pull forward as much as the text to delete the location of the mention.
            var newUsers: [(String, NSRange)] = []
            var removeRange = range
            
            for oldUser in highlightUsers {
                if removeRange.location >= oldUser.1.location + oldUser.1.length {
                    // The starting point of erasing is behind my mention (not affected by erasing)
                    newUsers.append(oldUser)
                } else if removeRange.location >= oldUser.1.location && removeRange.location < oldUser.1.location + oldUser.1.length {
                    // The starting point to erase is inside my mention (removing the existing mention)
                    
                    if deleteType == .delete {
                        let range = NSRange(location: oldUser.1.location, length: oldUser.1.length - removeRange.length)
                        self.text = self.text.replacing("", range: range)
                        
                        removeRange = oldUser.1
                    }
                    
                    continue
                } else {
                    // The starting point to erase is in front of my mention
                    
                    // Determining whether the end point to be erased is in or out of my mention (only the mention that was applied at this time is removed).
                    if removeRange.location + removeRange.length > oldUser.1.location {
                        continue
                    } else {
                        // Erasing the mention from my front
                        // As much as you erase, the mention is positioned forward.
                        let newRange = NSRange(location: max(0, oldUser.1.location - removeRange.length), length: oldUser.1.length)
                        newUsers.append((oldUser.0, newRange))
                    }
                }
            }
            
            highlightUsers = newUsers
        }
        
        highlightUsers.sort(by: { (lhs, rhs) -> Bool in
            return lhs.1.location < rhs.1.location
        })
    }
}
