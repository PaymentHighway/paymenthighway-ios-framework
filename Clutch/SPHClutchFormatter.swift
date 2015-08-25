//
//  SPHClutchFormatter.swift
//  Clutch
//
//  Created by Nico Hämäläinen on 01/04/15.
//  Copyright (c) 2015 Solinor Oy. All rights reserved.
//

import Foundation

// MARK: Text Pattern Callbacks
public typealias TextPatternMatchedBlock    = ((String, String, Int) -> (text: String, attributes: [NSObject: AnyObject]?))?
public typealias TextPatternMatchAttributes = [NSObject: AnyObject]?


/// TextPattern Representation Class
public class TextPattern {
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
		next()
	}
	
	/// Move to the next character index and process it
	public func next() -> Bool {
		index++
		if index >= count(text) { return true }
		
		current = text[advance(text.startIndex, index)]
		if current == "?" {
			next()
			mustFullfill = false
			rewindIndex = index
		}
		
		return false
	}

	/// Rewind to previous rewindIndex position
	public func rewind() -> Bool {
		if index > rewindIndex && rewindIndex > 0 {
			index = rewindIndex
			current = text[advance(text.startIndex, rewindIndex)]
			return true
		}
		
		return false
	}
}


/// Represents
public class TextMatcher {
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
public func ==(lhs: TextPattern, rhs: TextPattern) -> Bool {
	return lhs.text == rhs.text && lhs.start == rhs.start
}


public class SPHClutchFormatter {
	/// The patterns array holds all the variables that make up a pattern
	var patterns: [TextMatcher] = []
	
	/// Returns the character used for attachments
	public var attachmentString: String {
		return "\(Character(UnicodeScalar(NSAttachmentCharacter)))"
	}
	
	/// Init does nothing
	public init () { }
	
	/// Add a new pattern for the formatter
	public func add(pattern: String, recursive: Bool, matched: TextPatternMatchedBlock) {
		patterns.append(TextMatcher(source: pattern, recursive: recursive, matched: matched))
	}
	
	/// Process a given text source with our patterns
	public func process(source: String) -> NSAttributedString {
		var pending = Array<TextPattern>()
		var collect = Array<TextPattern>()
		var index = 0
		var text = source
		for char in text {
			var consumed = false
			var lastChar: Character?
			for pattern in pending.reverse() {
				if char != pattern.current && pattern.mustFullfill {
					pending = pending.filter{$0 != pattern}
				} else if char == pattern.current {
					if lastChar == char {
						lastChar = nil
						continue //it is matching on the same pattern, so skip it
					}
					if pattern.next() {
						let range = advance(text.startIndex, pattern.start)...advance(text.startIndex, index)
						//println("text range: \(text[range])")
						if let match = pattern.matched {
							let src = text[range]
							let srcLen = count(src)
							var replace = match(src,text,pattern.start)
							if replace.attributes != nil {
								text.replaceRange(range, with: replace.text)
								let replaceLen = count(replace.text)
								index -= (srcLen-replaceLen)
								lastChar = char
								pattern.length = replaceLen
								pattern.attributes = replace.attributes
							}
						}
						pending = pending.filter{$0 != pattern}
						consumed = true
						if pattern.length > -1 {
							collect.append(pattern)
						}
					}
				} else {
					if pattern.rewind() && !pattern.recursive {
						pending = pending.filter{$0 != pattern}
					}
				}
			}
			//process to see if a new pattern is matched
			if !consumed {
				for matchable in patterns {
					if char == matchable.source[matchable.source.startIndex] {
						pending.append(TextPattern(matchable.source, index, matchable.recursive, matchable.matched))
					}
				}
			}
			index++
		}
		//we have our patterns, let's build a stylized string
		var attributedText = NSMutableAttributedString(string: text)
		for pattern in collect {
			attributedText.setAttributes(pattern.attributes, range: NSMakeRange(pattern.start, pattern.length))
		}
		return attributedText
	}
}










