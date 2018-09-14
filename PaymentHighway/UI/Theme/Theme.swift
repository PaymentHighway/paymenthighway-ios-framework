//
//  Theme.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

/// Interface to define the look and feel of Payment Highway UI Elements
///
public protocol Theme: class {

    /// Animation duration for the placeholder label
    ///
    var placeholderAnimationDuration: Double { get set }
    
    /// Border Radius to make Text Field rounded
    ///
    var borderRadius: CGFloat { get set }

    /// Placeholder label font scale.
    ///
    /// Text field when focused or not empty show the placeholder label above the text with a smaller font
    var placeholderFontScale: CGFloat { get set }
    
    /// Border width
    ///
    var borderWidth: CGFloat { get set }
    
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

    /// Color used in all the important ui elements like buttons
    ///
    var highlightColor: UIColor { get set }
    
    /// Color used in all the important ui elements like buttons when disabled
    ///
    var highlightDisableColor: UIColor { get set }
    
    /// If true show automatically the keyboard with focus in the first text field
    ///
    var showKeyboard: Bool { get set }

    /// Font used for all the bold text in the views
    ///
    var emphasisFont: UIFont { get set }

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
}

extension Theme {
    
    func textColor(isActive: Bool) -> UIColor {
        return isActive ? primaryActiveForegroundColor : primaryForegroundColor
    }
    
    func borderColor(isActive: Bool, showError: Bool) -> UIColor {
        if showError {
            return isActive ? errorActiveForegroundColor : errorForegroundColor
        }
        return isActive ? secondaryActiveForegroundColor : secondaryForegroundColor
    }
    
    func placeholderLabelColor(isActive: Bool, showError: Bool) -> UIColor {
        if showError {
            return isActive ? errorActiveForegroundColor : errorForegroundColor
        }
        return isActive ? secondaryActiveForegroundColor : secondaryForegroundColor
    }
}
