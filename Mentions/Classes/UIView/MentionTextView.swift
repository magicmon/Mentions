//
//  MentionTextView.swift
//  Mentions
//
//  Created by magicmon on 2017. 3. 28..
//
//

import UIKit

public class MentionTextView: UITextView {
    
    public var highlightColor: UIColor = UIColor.blue
    public var pattern: ParserPattern = .mention
    
    var replaceValues: (oldText: String?, range: NSRange?, replacementText: String?) = (nil, nil, nil)
    
    var highlightUsers: [(String, NSRange)] = []        // 맨션 유저의 리스트
    
    public var mentionText: String? {
        get {
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
        } set {
            let (matchText, matchUsers) = self.parse(newValue, pattern: pattern, template: "$1")
            
            self.text = matchText
            
            if let matchUsers = matchUsers {
                highlightUsers.removeAll()
                for (user, range) in matchUsers {
                    highlightUsers.append(user, range)
                }
                
                refresh()
            }
        }
    }
    
    // MARK: override
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        
        self.autocorrectionType = .no
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        delegate = self
        
        self.autocorrectionType = .no
    }
    
}

// MARK: - Highlight
extension MentionTextView {
    public func insert(to user: String?, with nsrange: NSRange?) {
        guard let user = user, var nsrange = nsrange else {
            return
        }
        
        guard user.utf16.count > 0 else {
            return
        }
        
        // 추가하려는 텍스트의 range 위치 셋팅.
        var convertLength = min(text.utf16.count, nsrange.location + nsrange.length)
        if convertLength >= text.utf16.count { convertLength = 0 }
        nsrange = NSRange.init(location: min(text.utf16.count, nsrange.location), length: convertLength)
        guard let range = self.text.rangeFromNSRange(nsrange) else {
            return
        }
        
        // 변환 값 셋팅
        replaceValues = (text, nsrange, "@\(user)")
        
        // 변환된 맨션을 텍스트뷰에 추가
        
        // 텍스트 수정(맨션 문자 + 닉네임)
        self.text = self.text.replacingCharacters(in: range, with: "@\(user)")
        
        // 맨션 위치 재 정렬
        self.textViewDidChange(self)
        
        // 리스트에 맨션 영역 추가
        let insertRange = NSRange.init(location: nsrange.location, length: user.utf16.count + 1)
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
        
        guard var range = replaceValues.range else {
            return
        }
        
        guard let replacementText = replaceValues.replacementText else {
            return
        }
        
        if replacementText.utf16.count > 0 {
            // 텍스트 추가
            
            // 텍스트를 입력해서 추가했는데도 길이가 변하지 않은 경우
            // (중성이나 종성을 추가하면 입력했지만 실제로 전체길이에는 영향을 받지 않는다)
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
            // 텍스트 삭제
            
            // 지웠는데도 길이가 안변한 경우
            // (중성이나 종성을 지워도 실제로 전부 지워진게 아니기 때문에 별다른 처리를 하지 않음)
            if replaceValues.oldText?.utf16.count == textView.text.utf16.count {
                return
            }
            
            // 지우는 텍스트에 내 맨션이 포함됐는지 아닌지만 판단하면 된다.
            // 내 맨션이 포함 됐으면, 맨션을 제거하고
            // 그렇지 않으면 맨션의 location을 지우는 텍스트 만큼 앞으로 당긴다
            var newUsers: [(String, NSRange)] = []
            for oldUser in highlightUsers {
                
                if range.location >= oldUser.1.location + oldUser.1.length {
                    // 지우는 시작점이 내 맨션 뒤쪽(지우는거에 영향을 안받음)
                    newUsers.append(oldUser)
                } else if range.location >= oldUser.1.location && range.location < oldUser.1.location + oldUser.1.length {
                    // 지우는 시작점이 내 맨션 안쪽(기 적용된 맨션 제거)
                    continue
                } else {
                    // 지우는 시작점이 내 맨션 앞쪽
                    
                    // 지우는 끝지점이 내 맨션안에 있는지, 넘어가는지(이 때만 기 적용된 맨션 제거)
                    if range.location + range.length > oldUser.1.location {
                        continue
                    } else {
                        // 내 앞쪽에서 맨션을 지우는 중
                        // 지우는 만큼 맨션의 위치를 앞으로 땡긴다.
                        let newRange = NSRange.init(location: max(0, oldUser.1.location - range.length), length: oldUser.1.length)
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
