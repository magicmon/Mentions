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
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        delegate = self
    }
    
    var highlightUsers: [(String, NSRange)] = []        // 맨션 유저의 리스트
    
    public var mentionText: String {
        get {
            return self.text
        } set {
            let (matchText, matchUsers) = self.parse(newValue, pattern: pattern, template: "$1")
            
            self.text = matchText
            
            if let matchUsers = matchUsers {
                highlightUsers.removeAll()
                for (user, range) in matchUsers {
                    highlightUsers.append(user, range)
                }
                
                refreshAttributedText()
            }
        }
    }
}

// MARK: - Highlight
extension MentionTextView {
    func insert(to user: String?, with nsrange: NSRange?) {
        guard let user = user, let nsrange = nsrange else {
            return
        }
        
        guard let range = self.text.rangeFromNSRange(nsrange) else {
            return
        }
        
        // 변환된 맨션을 텍스트뷰에 추가
        
        // 넣기전 기존의 맨션 위치 재 정렬
        self.textView(self, shouldChangeTextIn: nsrange, replacementText: "@\(user)")
        
        // 텍스트 수정(맨션 문자 + 닉네임)
        self.text = self.text.replacingCharacters(in: range, with: "@\(user)")
        
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
        if text.utf16.count > 0 {
            // 텍스트 추가
            
            // check point
            // 내 맨션 앞인지
            // 내 맨션 중간인지
            // 내 맨션 뒤쪽인지
            var newUsers: [(String, NSRange)] = []
            for oldUser in highlightUsers {
                if range.location <= oldUser.1.location {
                    // 추가하는 시작점이 내 앞쪽(추가하는 만큼 맨션의 위치를 뒤로 이동)
                    let newRange = NSRange.init(location: max(0, oldUser.1.location + (text.utf16.count - range.length)), length: oldUser.1.length)
                    newUsers.append((oldUser.0, newRange))
                } else if range.location > oldUser.1.location && range.location < oldUser.1.location + oldUser.1.length {
                    // 추가하는 시작점이 내 맨션 안쪽
                    continue
                } else {
                    // 추가하는 시작점이 내 맨션 뒤쪽
                    newUsers.append(oldUser)
                }
            }
            
            highlightUsers = newUsers
        } else {
            // 텍스트 삭제
            
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
        
        return true
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        refresh()
    }
}
