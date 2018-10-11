//
//  Extensions.swift
//  PaymentHighway
//
//  Copyright (c) 2018 Payment Highway Oy. All rights reserved.
//
import Foundation

// MARK: Colors
extension UIColor {
	
    /// Convenience method for initializing with 0-255 color values
    /// - parameter red:   The red color value
    /// - parameter green: The green color value
    /// - parameter blue:  The blue color value
    /// - parameter alpha: The alpha value
    public convenience init(red: Int, green: Int, blue: Int, alpha: Int = 255) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        assert(alpha >= 0 && alpha <= 255, "Invalid alpha component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha) / 255.0)
    }
	
    /// Convenience method for initializing with a 0xFFFFFF-0x000000 color value
    /// - parameter hexInt: The hexadecimal integer color value
    public convenience init(hexInt: Int) {
        self.init(red: (hexInt >> 16) & 0xff, green: (hexInt >> 8) & 0xff, blue: hexInt & 0xff)
    }
}
