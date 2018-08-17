//
//  MentionLabel.swift
//  Mentions
//
//  Created by magicmon on 2017. 3. 30..
//
//

import UIKit

public class MentionLabel: UILabel {

    fileprivate lazy var textStorage = NSTextStorage()
    fileprivate lazy var layoutManager = NSLayoutManager()
    fileprivate lazy var textContainer = NSTextContainer()
    
    fileprivate var heightCorrection: CGFloat = 0
    fileprivate var clickableRanges: [NSRange] = []
    fileprivate var selectedRange: NSRange?
    
    @IBInspectable public var highlightColor: UIColor = UIColor.blue
    @IBInspectable public var prefixMention: String = "@"
    public var pattern: ParserPattern = .mention
    
    public var tapHandler: ((String) -> ())?
    
    override public var text: String? {
        didSet {
            clickableRanges.removeAll()
            
            let (matchText, matchUsers) = self.parse(self.text, pattern: pattern, template: "$1", prefixMention: prefixMention)
            
            if let matchText = matchText {
                var attributes = [NSAttributedStringKey.font: self.font,
                                  NSAttributedStringKey.foregroundColor: self.textColor] as [NSAttributedStringKey : Any]
                let muAttrString = NSAttributedString(string: matchText)
                textStorage.setAttributedString(muAttrString)
                textStorage.setAttributes(attributes, range: NSRange(location: 0, length: muAttrString.length))
                
                // append attributes
                if let matchUsers = matchUsers {
                    for (_, range) in matchUsers {
                        clickableRanges.append(range)
                        attributes[NSAttributedStringKey.foregroundColor] = highlightColor
                        textStorage.setAttributes(attributes, range: range)
                    }
                }
                self.attributedText = muAttrString
            } else {
                textStorage.setAttributedString(NSAttributedString())
                self.attributedText = NSAttributedString()
            }
            
            setNeedsDisplay()
        }
    }
    
    // MARK: - init functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLabel()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupLabel()
    }
    
    
    override public func drawText(in rect: CGRect) {
        let range = NSRange(location: 0, length: textStorage.length)
        
        textContainer.size = rect.size
        let newOrigin = textOrigin(inRect: rect)
        
        layoutManager.drawBackground(forGlyphRange: range, at: newOrigin)
        layoutManager.drawGlyphs(forGlyphRange: range, at: newOrigin)
    }
    
    fileprivate func textOrigin(inRect rect: CGRect) -> CGPoint {
        let usedRect = layoutManager.usedRect(for: textContainer)
        heightCorrection = (rect.height - usedRect.height) / 2
        let glyphOriginY = heightCorrection > 0 ? rect.origin.y + heightCorrection : rect.origin.y
        return CGPoint(x: rect.origin.x, y: glyphOriginY)
    }
    
    func setupLabel() {
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = 0
        
        isUserInteractionEnabled = true
    }
}

// MARK: - touch events
extension MentionLabel {
    
    //MARK: - Handle UI Responder touches
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if onTouch(touch) { return }
        super.touchesBegan(touches, with: event)
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if onTouch(touch) { return }
        super.touchesMoved(touches, with: event)
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        _ = onTouch(touch)
        super.touchesCancelled(touches, with: event)
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if onTouch(touch) { return }
        super.touchesEnded(touches, with: event)
    }
    
    
    
    func onTouch(_ touch: UITouch) -> Bool {
        let location = touch.location(in: self)
        var avoidSuperCall = false
        
        switch touch.phase {
        case .began, .moved:
            if let element = elementAtLocation(location) {
                if element.location != selectedRange?.location || element.length != selectedRange?.length {
                    selectedRange = element
                }
                avoidSuperCall = true
            } else {
                selectedRange = nil
            }
        case .ended:
            guard let selectedRange = selectedRange else { return avoidSuperCall }
            
            let selectText = textStorage.attributedSubstring(from: selectedRange).string.removePrefix("@")
            tapHandler?(selectText)
            
            self.selectedRange = nil
            
            avoidSuperCall = true
        case .cancelled:
            selectedRange = nil
        case .stationary:
            break
        }
        
        return avoidSuperCall
    }
    
    fileprivate func elementAtLocation(_ location: CGPoint) -> NSRange? {
        guard textStorage.length > 0 else {
            return nil
        }
        
        var correctLocation = location
        correctLocation.y -= heightCorrection
        let boundingRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: 0, length: textStorage.length), in: textContainer)
        guard boundingRect.contains(correctLocation) else {
            return nil
        }
        
        let index = layoutManager.glyphIndex(for: correctLocation, in: textContainer)
        
        for clickableRange in clickableRanges {
            if index >= clickableRange.location && index <= clickableRange.location + clickableRange.length {
                return clickableRange
            }
        }
        
        return nil
    }
}
