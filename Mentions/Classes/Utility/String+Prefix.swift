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
            return replacement + String(self[prefix.endIndex...])
        } else {
            return self
        }
    }
    
    func removePrefix(_ prefix: String) -> String {
        if hasPrefix(prefix) {
            return String(self[prefix.endIndex...])
        } else {
            return self
        }
    }
    
    func removeSuffix(_ suffix: String) -> String {
        if hasSuffix(suffix) {
            return String(self[..<self.index(self.endIndex, offsetBy: -suffix.count)])
        } else {
            return self
        }
    }
}
