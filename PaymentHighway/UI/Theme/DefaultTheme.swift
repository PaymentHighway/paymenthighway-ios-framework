//
//  DefaultTheme.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

private let defaultBarTintColor =  UIColor(hexInt: 0xf6f6f6)
private let defaultBackgroundColor = UIColor.white
private let defaultPrimaryForegroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 153)
private let defaultPrimaryActiveForegroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 222)
private let defaultSecondaryForegroundColor = UIColor(hexInt: 0x9d00ba)
private let defaultSecondaryActiveForegroundColor = defaultSecondaryForegroundColor
private let defaultErrorForegroundColor = UIColor.red
private let defaultErrorActiveForegroundColor = UIColor.red
private let defaultHighlightColor = defaultSecondaryForegroundColor
private let defaultHighlightDisableColor = UIColor(red: 124, green: 124, blue: 124, alpha: 153)

private let defaultRoundedBorderRadius: CGFloat = 28
private let defaultPlaceholderFontScale: CGFloat = 0.8
private let defaultBorderWidth: CGFloat = 1.5
private let defaultPlaceholderAnimationDuration: Double = 0.25
private let defaultFontSize: CGFloat = 13
private let defaultTextImageHeight: CGFloat = 24
private let defaultTextPaddingX: CGFloat = 24.0
private let defaultShowKeyboard = false
private let defaultExpiryDatePicker = false

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
    
    /// returns height of the Text Field image
    ///
    public var textImageHeight: CGFloat
    
    /// X padding for Text Field
    ///
    public var textPaddingX: CGFloat
    
    /// Bar tin color
    ///
    public var barTintColor: UIColor
    
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
    
    /// Expiry date picker enabled
    ///
    public var expiryDatePicker: Bool
    
    public init() {
        placeholderAnimationDuration = defaultPlaceholderAnimationDuration
        borderRadius = defaultRoundedBorderRadius
        placeholderFontScale = defaultPlaceholderFontScale
        borderWidth = defaultBorderWidth
        textImageHeight = defaultTextImageHeight
        textPaddingX = defaultTextPaddingX
        barTintColor = defaultBarTintColor
        primaryBackgroundColor = defaultBackgroundColor
        secondaryBackgroundColor = defaultBackgroundColor
        primaryForegroundColor = defaultPrimaryForegroundColor
        primaryActiveForegroundColor = defaultPrimaryActiveForegroundColor
        secondaryForegroundColor = defaultSecondaryForegroundColor
        secondaryActiveForegroundColor = defaultSecondaryActiveForegroundColor
        errorForegroundColor = defaultErrorForegroundColor
        errorActiveForegroundColor = defaultErrorActiveForegroundColor
        highlightColor = defaultHighlightColor
        highlightDisableColor = defaultHighlightDisableColor
        showKeyboard = defaultShowKeyboard
        emphasisFont = UIFont.systemFont(ofSize: defaultFontSize+1, weight: .bold)
        font = UIFont.systemFont(ofSize: defaultFontSize, weight: .regular)
        expiryDatePicker = defaultExpiryDatePicker
    }
    
    open func textImageView(textFieldType: TextFieldType, cardBrand: CardBrand? = nil) -> UIView? {
        let iconImageView = UIImageView(frame: CGRect.zero)
        iconImageView.image = UIImage(named: textFieldType.iconId(cardBrand: cardBrand),
                                      in: Bundle(for: type(of: self)),
                                      compatibleWith: nil)
        iconImageView.frame = CGRect(x: 0, y: 0, width: textImageHeight, height: textImageHeight)
        iconImageView.contentMode = UIViewContentMode.scaleAspectFit
        return iconImageView
    }
}
