//
//  Extensions.swift
//  Clutch
//
//  Created by Nico Hämäläinen on 30/03/15.
//  Copyright (c) 2015 Solinor Oy. All rights reserved.
//
import Foundation

// MARK: Reused Objects and Utility Functions

public struct Inset {
	let x: CGFloat
	let y: CGFloat
	
	init(_ x: CGFloat, _ y: CGFloat) {
		self.x = x
		self.y = y
	}
}


// MARK: Strings

internal extension String {

	/// Get a given substring of a string
	/// - parameter r: The range of the substring wanted
	/// - returns: The found substring
	subscript (r: Range<Int>) -> String {
		get {
			let startIndex = self.characters.index(self.startIndex, offsetBy: r.lowerBound)
			let endIndex = self.characters.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
			
			return self[(startIndex ..< endIndex)]
		}
	}
    /// Returns matches for given regexp
    /// - parameter regex: The pattern to evaluate
    /// - returns: Found matches as an array
    func matchesForRegex(_ regex: String!) -> [String] {
        
        let regex = try! NSRegularExpression(pattern: regex,
            options: [])
        let nsString = self as NSString
        let results = regex.matches(in: nsString as String,
            options: [], range: NSMakeRange(0, nsString.length))
            
		
        var strings = [String]()
        
        for result in results {
            for i in 1 ..< result.numberOfRanges {
                let range = result.rangeAt(i)
                strings.append(nsString.substring(with: range))
            }
        }
        
        return strings
    }
    
    /// Truncates the string to length number of characters and
    /// appends optional trailing string if longer
    /// Source: https://gist.github.com/aorcsik/c8210a84f163b1b644c0
    func truncate(_ length: Int, trailing: String? = nil) -> String {
        if self.characters.count > length {
            return self.substring(to: self.characters.index(self.startIndex, offsetBy: length)) + (trailing ?? "")
        } else {
            return self
        }
    }
	
}

// MARK: Colors

internal extension UIColor {
	
	/// Convenience method for initializing with 0-255 color values
	/// - parameter red:   The red color value
	/// - parameter green: The green color value
	/// - parameter blue:  The blue color value
	convenience init(red: Int, green: Int, blue: Int) {
		assert(red >= 0 && red <= 255, "Invalid red component")
		assert(green >= 0 && green <= 255, "Invalid green component")
		assert(blue >= 0 && blue <= 255, "Invalid blue component")
		
		self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
	}
	
	/// Convenience method for initializing with a 0xFFFFFF-0x000000 color value
	/// - parameter hexInt: The hexadecimal integer color value
	convenience init(hexInt: Int) {
		self.init(red: (hexInt >> 16) & 0xff, green: (hexInt >> 8) & 0xff, blue: hexInt & 0xff)
	}
}

// MARK: Clutch User Interface Hooks

public extension UIViewController {
	
    public func presentSPHAddCardViewController(_ source: UIViewController, animated: Bool, transactionId : String, success: @escaping (String) -> (), error: @escaping (NSError) -> (), completion: (() -> Void)?) {
		let storyboard = UIStoryboard(name: "SPHClutch", bundle: Bundle(for: SPHClutch.self))
		let controller = storyboard.instantiateViewController(withIdentifier: "SPHAddCardForm") as! SPHAddCardViewController
        controller.transactionId = transactionId
        controller.successHandler = success
        controller.errorHandler = error
        
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        let ppc = nav.popoverPresentationController!
        let minimunSize = controller.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        controller.preferredContentSize = CGSize(width: minimunSize.width, height: minimunSize.height)
        ppc.delegate = controller
        ppc.sourceView = source.view
		self.present(nav, animated: animated, completion: completion)
	}
	
}
