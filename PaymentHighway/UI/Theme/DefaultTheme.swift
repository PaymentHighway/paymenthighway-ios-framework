//
//  DefaultTheme.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 01/08/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

private let defaulBackgroundColor = UIColor.white
private let defaultPrimaryForegroundColor = UIColor(hexInt: 0xa6b9dc)
private let defaultPrimaryActiveForegroundColor = UIColor(hexInt: 0x000000)
private let defaultSecondaryForegroundColor = UIColor(hexInt: 0xa6b9dc)
private let defaultSecondaryActiveForegroundColor = UIColor(hexInt: 0x636f84)
private let defaultErrorForegroundColor = UIColor(hexInt: 0xe80f0f)
private let defaultErrorActiveForegroundColor = UIColor(hexInt: 0x993333)

private let defaulRoundedBorderRadius: CGFloat = 20
private let defaultPlaceholderFontScale: CGFloat = 0.7
private let defaulBorderWidth: CGFloat = 1.5
private let defaulPlaceholderAnimationDuration: Double = 0.25
private let defaultFontSize: CGFloat = 13.0
private let defaultTextImages: [TextFieldType] = [.cardNumber, .expirationDate, .securityCode]
private let defaultTextPaddingX: CGFloat = 20.0
private let defaultShowKeyboard = false
private let defaultAddCardPresentationType: PresentationType = .custom(280)

/// Default implementation of the Theme
///
/// - seealso: `Theme`
open class DefaultTheme : Theme {
    
    /// Singleton instance of the default theme
    ///
    public static let instance: DefaultTheme = DefaultTheme()

    /// Animation duration for the placeholder label
    ///
    open var placeholderAnimationDuration: Double = defaulPlaceholderAnimationDuration
    
    /// If true make the TextField rounded.
    ///
    /// - seealso: roundedBorderRadius
    ///
    open var textFieldRounded: Bool = true
    
    /// Border Radius when the TextField is rounded
    ///
    open var roundedBorderRadius: CGFloat = defaulRoundedBorderRadius

    /// Placeholder label font scale.
    ///
    /// Text field when focused or not empty show the placeholder label above the text with a smaller font
    open var placeholderFontScale: CGFloat = defaultPlaceholderFontScale
    
    /// Border width
    ///
    open var borderWidth: CGFloat = defaulBorderWidth
    
    /// returns which TextFields will have image
    ///
    open var textImages: [TextFieldType] = defaultTextImages
    
    /// X padding for Text Field
    ///
    open var textPaddingX: CGFloat = defaultTextPaddingX
    
    /// View background color
    ///
    open var primaryBackgroundColor: UIColor = defaulBackgroundColor
    
    /// Background color for all subviews like TextFields
    ///
    open var secondaryBackgroundColor: UIColor = defaulBackgroundColor
    
    /// Text color for any text field in a view
    ///
    open var primaryForegroundColor: UIColor = defaultPrimaryForegroundColor
    
    /// Text color for any text field in a view when is active/focused
    ///
    open var primaryActiveForegroundColor: UIColor = defaultPrimaryActiveForegroundColor
    
    /// Border color for any text field in a view
    ///
    open var secondaryForegroundColor: UIColor = defaultSecondaryForegroundColor
    
    /// Border color for any text field in a view when is active/focused
    ///
    open var secondaryActiveForegroundColor: UIColor = defaultSecondaryActiveForegroundColor
    
    /// Text and Border color for any text field in case of error
    ///
    open var errorForegroundColor: UIColor = defaultErrorForegroundColor
 
    /// Text and Border color for any text field in case of error when is active/focused
    ///
    open var errorActiveForegroundColor: UIColor = defaultErrorActiveForegroundColor
    
    /// If true show automatically the keyboard with focus in the first text field
    ///
    open var showKeyboard: Bool = defaultShowKeyboard
    
    /// Add Card ViewController `PresentationType`
    ///
    open var addCardPresentationType: PresentationType = defaultAddCardPresentationType

    /// Font used in the views
    ///
    open var font: UIFont = UIFont.systemFont(ofSize: defaultFontSize, weight: .regular)
    
    public init() {}
}
