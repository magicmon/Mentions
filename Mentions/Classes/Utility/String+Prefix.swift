//
//  String+Prefix.swift
//  Mentions
//
//  Created by magicmon on 2017. 3. 30..
//
//

import UIKit

extension String {
    
    func replacePrefix(_ prefix: String, replacement: String) -> String {
        if hasPrefix(prefix) {
            return replacement + substring(from: prefix.endIndex)
        } else {
            return self
        }
    }
    
    func removePrefix(_ prefix: String) -> String {
        if hasPrefix(prefix) {
            return substring(from: prefix.endIndex)
        } else {
            return self
        }
    }
    
    func removeSuffix(_ suffix: String) -> String {
        if hasSuffix(suffix) {
            return substring(to: self.characters.index(self.endIndex, offsetBy: -suffix.characters.count))
        } else {
            return self
        }
    }
}
