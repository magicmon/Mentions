//
//  AttributedTextUtility+Append.swift
//  Mentions
//
//  Created by magicmon on 2017. 3. 28..
//
//

import UIKit

extension NSMutableAttributedString {
    
    @discardableResult public func appendText(_ text: String, font: UIFont, color: UIColor) -> NSMutableAttributedString {
        let attributes = [NSAttributedString.Key.foregroundColor: color,
                          NSAttributedString.Key.font: font] as [NSAttributedString.Key : Any]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        self.append(attributedText)
        
        return self
    }
    
    @discardableResult public func addAttributes(_ font: UIFont, color: UIColor, range: NSRange) -> NSMutableAttributedString {
        let attributes = [NSAttributedString.Key.foregroundColor: color,
                          NSAttributedString.Key.font: font] as [NSAttributedString.Key : Any]
        self.addAttributes(attributes, range: range)
        
        return self
    }
}
