//
//  SPHFormatter.swift
//  PaymentHighway
//
//  Created by Nico Hämäläinen on 01/04/15.
//  Copyright (c) 2015 Payment Highway Oy. All rights reserved.
//

import Foundation

// MARK: Text Pattern Callbacks
public typealias TextPatternMatchedBlock    = ((String, String, Int) -> (text: String, attributes: [AnyHashable: Any]?))?
public typealias TextPatternMatchAttributes = [AnyHashable: Any]?

/// TextPattern Representation Class
open class TextPattern {
    /// Callback Block for Matches
    var matched: TextPatternMatchedBlock

    /// Positions
    var start: Int = 0
    var length: Int = -1

    /// Winding
    var index: Int = 0
    var rewindIndex: Int = 0

    /// Match processing
    var attributes: TextPatternMatchAttributes

    /// Pattern text
    var text: String

    /// Recursively search through patterns
    var recursive: Bool = false

    /// The current characer being processed
    var current: Character

    /// Whether or not the pattern must be fullfilles
    var mustFullfill: Bool = true

    // MARK: Initializers

    public init(_ text: String, _ start: Int, _ recursive: Bool, _ matched: TextPatternMatchedBlock) {
        self.text = text
        self.matched = matched
        self.current = text[text.startIndex]
        _ = next()
    }

    /// Move to the next character index and process it
    open func next() -> Bool {
        index += 1
        if index >= text.count { return true }
        
        current = text[text.index(text.startIndex, offsetBy: index)]
        if current == "?" {
            _ = next()
            mustFullfill = false
            rewindIndex = index
        }
        
        return false
    }

    /// Rewind to previous rewindIndex position
    open func rewind() -> Bool {
        if index > rewindIndex && rewindIndex > 0 {
            index = rewindIndex
            current = text[text.index(text.startIndex, offsetBy: rewindIndex)]
            return true
        }
        
        return false
    }
}

/// Represents
open class TextMatcher {
    var source: String
    var recursive: Bool
    var matched: TextPatternMatchedBlock

    public init(source: String, recursive: Bool, matched: TextPatternMatchedBlock) {
        self.source = source
        self.recursive = recursive
        self.matched = matched
    }
}

extension TextPattern: Equatable { }

public func == (lhs: TextPattern, rhs: TextPattern) -> Bool {
    return lhs.text == rhs.text && lhs.start == rhs.start
}

open class SPHFormatter {
    /// The patterns array holds all the variables that make up a pattern
    var patterns: [TextMatcher] = []

    /// Returns the character used for attachments
    open var attachmentString: String {
        return "\(Character(UnicodeScalar(NSAttachmentCharacter)!))"
    }

    /// Init does nothing
    public init () { }

    /// Add a new pattern for the formatter
    open func add(_ pattern: String, recursive: Bool, matched: TextPatternMatchedBlock) {
        patterns.append(TextMatcher(source: pattern, recursive: recursive, matched: matched))
    }

    /// Process a given text source with our patterns
    // swiftlint:disable function_body_length cyclomatic_complexity
    open func process(_ source: String) -> NSAttributedString {
        var pending = [TextPattern]()
        var collect = [TextPattern]()
        var index = 0
        var text = source
        for char in text {
            var consumed = false
            var lastChar: Character?
            for pattern in Array(pending.reversed()) {
                if char != pattern.current && pattern.mustFullfill {
                    pending = pending.filter {$0 != pattern}
                } else if char == pattern.current {
                    if lastChar == char {
                        lastChar = nil
                        continue //it is matching on the same pattern, so skip it
                    }
                    if pattern.next() {
                        let range = text.index(text.startIndex, offsetBy: pattern.start)...text.index(text.startIndex, offsetBy: index)
                        //println("text range: \(text[range])")
                        if let match = pattern.matched {
                            let src = text[range]
                            let srcLen = src.count
                            let replace = match(String(src), text, pattern.start)
                            if replace.attributes != nil {
                                text.replaceSubrange(range, with: replace.text)
                                let replaceLen = replace.text.count
                                index -= (srcLen-replaceLen)
                                lastChar = char
                                pattern.length = replaceLen
                                pattern.attributes = replace.attributes
                            }
                        }
                        pending = pending.filter {$0 != pattern}
                        consumed = true
                        if pattern.length > -1 {
                            collect.append(pattern)
                        }
                    }
                } else {
                    if pattern.rewind() && !pattern.recursive {
                        pending = pending.filter {$0 != pattern}
                    }
                }
            }
            //process to see if a new pattern is matched
            if !consumed {
                for matchable in patterns where char == matchable.source[matchable.source.startIndex] {
                    pending.append(TextPattern(matchable.source, index, matchable.recursive, matchable.matched))
                }
            }
            index += 1
        }
        //we have our patterns, let's build a stylized string
        let attributedText = NSMutableAttributedString(string: text)
        for pattern in collect {
            guard let attributes = pattern.attributes as? [NSAttributedStringKey: Any] else { continue }
            attributedText.setAttributes(attributes,
                                         range: NSRange(location: pattern.start, length: pattern.length))
        }
        return attributedText
    }
}
