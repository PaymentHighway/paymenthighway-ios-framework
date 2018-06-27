//
//  Extensions.swift
//  PaymentHighway
//
//  Created by Nico Hämäläinen on 30/03/15.
//  Copyright (c) 2015 Payment Highway Oy. All rights reserved.
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

// MARK: PaymentHighway User Interface Hooks

public extension UIViewController {
	
    @objc public func presentSPHAddCardViewController(_ source: UIViewController,
                                                      animated: Bool,
                                                      transactionId : String,
                                                      success: @escaping (String) -> Void,
                                                      error: @escaping (NSError) -> Void,
                                                      completion: (() -> Void)?) {
		let storyboard = UIStoryboard(name: "SPH", bundle: Bundle(for: SPH.self))
        // swiftlint:disable force_cast
        let controller = storyboard.instantiateViewController(withIdentifier: "SPHAddCardForm") as! SPHAddCardViewController
        controller.transactionId = transactionId
        controller.successHandler = success
        controller.errorHandler = error
        
        let navigation = UINavigationController(rootViewController: controller)
        navigation.modalPresentationStyle = UIModalPresentationStyle.popover
        let ppc = navigation.popoverPresentationController!
        let minimunSize = controller.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        controller.preferredContentSize = CGSize(width: minimunSize.width, height: minimunSize.height)
        ppc.delegate = controller
        ppc.sourceView = source.view
		source.present(navigation, animated: animated, completion: completion)
	}
	
}
