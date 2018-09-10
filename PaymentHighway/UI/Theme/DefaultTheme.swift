//
//  DefaultTheme.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

private let defaulBackgroundColor = UIColor.white
private let defaultPrimaryForegroundColor = UIColor(hexInt: 0x808080)
private let defaultPrimaryActiveForegroundColor = UIColor(hexInt:  0x000000)
private let defaultSecondaryForegroundColor = defaultPrimaryForegroundColor
private let defaultSecondaryActiveForegroundColor = defaultPrimaryActiveForegroundColor
private let defaultErrorForegroundColor = UIColor(hexInt:  0x993333)
private let defaultErrorActiveForegroundColor = UIColor(hexInt: 0xe80f0f)
private let defaultHighlightColor = UIColor(hexInt: 0x007AFF)
private let defaultHighlightDisableColor = UIColor.gray

private let defaulRoundedBorderRadius: CGFloat = 20
private let defaultPlaceholderFontScale: CGFloat = 0.7
private let defaulBorderWidth: CGFloat = 1.5
private let defaulPlaceholderAnimationDuration: Double = 0.25
private let defaultFontSize: CGFloat = 13.0
private let defaultTextImages: [TextFieldType] = [.cardNumber, .expiryDate, .securityCode]
private let defaultTextPaddingX: CGFloat = 20.0
private let defaultShowKeyboard = false

/// Default implementation of the Theme
///
/// - seealso: `Theme`
open class DefaultTheme : Theme {
    
    /// Singleton instance of the default theme
    ///
    public static let instance: DefaultTheme = DefaultTheme()

    /// Animation duration for the placeholder label
    ///
    public var placeholderAnimationDuration: Double
    
    /// Border Radius to make Text Field rounded
    ///
    public var borderRadius: CGFloat

    /// Placeholder label font scale.
    ///
    /// Text field when focused or not empty show the placeholder label above the text with a smaller font
    public var placeholderFontScale: CGFloat
    
    /// Border width
    ///
    public var borderWidth: CGFloat
    
    /// returns which TextFields will have image
    ///
    public var textImages: [TextFieldType]
    
    /// X padding for Text Field
    ///
    public var textPaddingX: CGFloat
    
    /// View background color
    ///
    public var primaryBackgroundColor: UIColor
    
    /// Background color for all subviews like TextFields
    ///
    public var secondaryBackgroundColor: UIColor
    
    /// Text color for any text field in a view
    ///
    public var primaryForegroundColor: UIColor
    
    /// Text color for any text field in a view when is active/focused
    ///
    public var primaryActiveForegroundColor: UIColor
    
    /// Border color for any text field in a view
    ///
    public var secondaryForegroundColor: UIColor
    
    /// Border color for any text field in a view when is active/focused
    ///
    public var secondaryActiveForegroundColor: UIColor
    
    /// Text and Border color for any text field in case of error
    ///
    public var errorForegroundColor: UIColor
 
    /// Text and Border color for any text field in case of error when is active/focused
    ///
    public var errorActiveForegroundColor: UIColor
    
    /// Color used in all the important ui elements like buttons
    ///
    public var highlightColor: UIColor
    
    /// Color used in all the important ui elements like buttons when disabled
    ///
    public var highlightDisableColor: UIColor
    
    /// If true show automatically the keyboard with focus in the first text field
    ///
    public var showKeyboard: Bool

    /// Font used for all the bold text in the views
    ///
    public var emphasisFont: UIFont
    
    /// Font used in the views
    ///
    public var font: UIFont
    
    public init() {
        self.placeholderAnimationDuration = defaulPlaceholderAnimationDuration
        self.borderRadius = defaulRoundedBorderRadius
        self.placeholderFontScale = defaultPlaceholderFontScale
        self.borderWidth = defaulBorderWidth
        self.textImages = defaultTextImages
        self.textPaddingX = defaultTextPaddingX
        self.primaryBackgroundColor = defaulBackgroundColor
        self.secondaryBackgroundColor = defaulBackgroundColor
        self.primaryForegroundColor = defaultPrimaryForegroundColor
        self.primaryActiveForegroundColor = defaultPrimaryActiveForegroundColor
        self.secondaryForegroundColor = defaultSecondaryForegroundColor
        self.secondaryActiveForegroundColor = defaultSecondaryActiveForegroundColor
        self.errorForegroundColor = defaultErrorForegroundColor
        self.errorActiveForegroundColor = defaultErrorActiveForegroundColor
        self.highlightColor = defaultHighlightColor
        self.highlightDisableColor = defaultHighlightDisableColor
        self.showKeyboard = defaultShowKeyboard
        self.emphasisFont = UIFont.systemFont(ofSize: defaultFontSize+1, weight: .bold)
        self.font = UIFont.systemFont(ofSize: defaultFontSize, weight: .regular)
    }
}
