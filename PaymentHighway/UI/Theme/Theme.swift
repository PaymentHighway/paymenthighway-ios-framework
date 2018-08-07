//
//  Theme.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 31/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

/// Interface to define the look and feel of Payment Highway UI Elements
///
public protocol Theme: class {

    /// Animation duration for the placeholder label
    ///
    var placeholderAnimationDuration: Double { get set }
    
    /// If true make the TextField rounded.
    ///
    /// - seealso: roundedBorderRadius
    ///
    var textFieldRounded: Bool { get set }

    /// Border Radius when the TextField is rounded
    ///
    var roundedBorderRadius: CGFloat { get set }

    /// Placeholder label font scale.
    ///
    /// Text field when focused or not empty show the placeholder label above the text with a smaller font
    var placeholderFontScale: CGFloat { get set }
    
    /// Border width
    ///
    var borderWidth: CGFloat { get set }
    
    /// Helper to return border radius depending if Text Field is rounded
    ///
    /// - seealso: default implementation of borderRadius
    var borderRadius: CGFloat { get }
    
    /// Helper to return border radius depending if value is valid and active/focused
    ///
    /// - parameter isValid: true if TextField data is valid
    /// - parameter isActive: true if TextField has focus
    /// - returns: border color
    /// - seealso: default implementation of borderColor
    func borderColor(isValid: Bool, isActive: Bool) -> UIColor
    
    /// Helper to returns placeholder label color depending if value is valid and active/focused
    ///
    /// - parameter isValid: true if TextField data is valid
    /// - parameter isActive: true if TextField has focus
    /// - returns: placeholder label color
    /// - seealso: default implementation of placeholderLabelColor
    func placeholderLabelColor(isValid: Bool, isActive: Bool) -> UIColor
    
    /// Helper to returns text color depending if value is valid and active/focused
    ///
    /// - parameter isValid: true if TextField data is valid
    /// - parameter isActive: true if TextField has focus
    /// - returns: text color
    /// - seealso: default implementation of textColor
    func textColor(isValid: Bool, isActive: Bool) -> UIColor
    
    /// Returns Text Field image
    ///
    /// - parameter textFieldType: `TextFieldType`
    /// - parameter height: image height
    /// - parameter cardBrand: cardBrand if available
    /// - seealso: TextFieldType and CardBrand
    /// - seealso: default implementation of textImageView
    func textImageView(textFieldType: TextFieldType, height: CGFloat, cardBrand: CardBrand?) -> UIImageView?
    
    /// returns which TextFields will have image
    ///
    var textImages: [TextFieldType] { get set }
    
    /// X padding for Text Field
    ///
    var textPaddingX: CGFloat { get set }
    
    /// View background color
    ///
    var primaryBackgroundColor: UIColor { get set }
    
    /// Background color for all subviews like TextFields
    ///
    var secondaryBackgroundColor: UIColor { get set }

    /// Text color for any text field in a view
    ///
    var primaryForegroundColor: UIColor { get set }

    /// Text color for any text field in a view when is active/focused
    ///
    var primaryActiveForegroundColor: UIColor { get set }
    
    /// Border color for any text field in a view
    ///
    var secondaryForegroundColor: UIColor { get set }

    /// Border color for any text field in a view when is active/focused
    ///
    var secondaryActiveForegroundColor: UIColor { get set }
    
    /// Text and Border color for any text field in case of error
    ///
    var errorForegroundColor: UIColor { get set }

    /// Text and Border color for any text field in case of error when is active/focused
    ///
    var errorActiveForegroundColor: UIColor { get set }
    
    /// If true show automatically the keyboard with focus in the first text field
    ///
    var showKeyboard: Bool { get set }
    
    /// Add Card ViewController `PresentationType`
    ///
    var addCardPresentationType: PresentationType { get set }
    
    /// Font used in the views
    ///
    var font: UIFont { get set }
}

extension Theme {

    public func textImageView(textFieldType: TextFieldType, height: CGFloat, cardBrand: CardBrand? = nil) -> UIImageView? {
        let iconImageView = UIImageView(frame: CGRect.zero)
        iconImageView.image = UIImage(named: textFieldType.iconId(cardBrand: cardBrand),
                                      in: Bundle(identifier: "io.paymenthighway.PaymentHighway"),
                                      compatibleWith: nil)
        iconImageView.frame = CGRect(x: 0, y: 0, width: height, height: height)
        iconImageView.contentMode = UIViewContentMode.scaleAspectFit
        return iconImageView
    }

    public var borderRadius: CGFloat {
        return textFieldRounded ? roundedBorderRadius : 0
    }
    
    public func textColor(isValid: Bool, isActive: Bool) -> UIColor {
        if isValid {
            return isActive ? primaryActiveForegroundColor : primaryForegroundColor
        }
        return isActive ? errorActiveForegroundColor : errorForegroundColor
    }
    
    public func borderColor(isValid: Bool, isActive: Bool) -> UIColor {
        if isValid {
            return isActive ? secondaryActiveForegroundColor : secondaryForegroundColor
        }
        return isActive ? errorActiveForegroundColor : errorForegroundColor
    }
    
    public func placeholderLabelColor(isValid: Bool, isActive: Bool) -> UIColor {
        if isValid {
            return isActive ? secondaryActiveForegroundColor : secondaryForegroundColor
        }
        return isActive ? errorActiveForegroundColor : errorForegroundColor
    }
}
