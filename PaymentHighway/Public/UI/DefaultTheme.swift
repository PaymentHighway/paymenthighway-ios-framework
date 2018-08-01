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

private let defaultPlaceholderInset = Inset(2, 4)
private let defaultTextFieldInsets = Inset(2, 0)
private let defaulRoundedBorderRadius: CGFloat = 20
private let defaultPlaceholderFontScale: CGFloat = 0.7
private let defaulBorderWidth: CGFloat = 1.5
private let defaulPlaceholderAnimationDuration: Double = 0.25
private let defaultFontSize: CGFloat = 13.0
private let defaultTextImages: [TextFieldType] = [.cardNumber, .expirationDate, .securityCode]
private let defaultTextAdjustX: CGFloat = 20.0
private let defaultShowKeyboard = false
private let defaultAddCardPresentationType: PresentationType = .custom(280)

open class DefaultTheme : Theme {
    
    public static let instance: DefaultTheme = DefaultTheme()
    
    open var placeholderAnimationDuration: Double = defaulPlaceholderAnimationDuration
    
    open var textFieldRounded: Bool = true
    
    open var placeholderFontScale: CGFloat = defaultPlaceholderFontScale
    
    open var roundedBorderRadius: CGFloat = defaulRoundedBorderRadius
    
    open var borderWidth: CGFloat = defaulBorderWidth
    
    open var textImages: [TextFieldType] = defaultTextImages
    
    open var textAdjustX: CGFloat = defaultTextAdjustX
    
    open var primaryBackgroundColor: UIColor = defaulBackgroundColor
    
    open var secondaryBackgroundColor: UIColor = defaulBackgroundColor
    
    open var primaryForegroundColor: UIColor = defaultPrimaryForegroundColor
    
    open var primaryActiveForegroundColor: UIColor = defaultPrimaryActiveForegroundColor
    
    open var secondaryForegroundColor: UIColor = defaultSecondaryForegroundColor
    
    open var secondaryActiveForegroundColor: UIColor = defaultSecondaryActiveForegroundColor
    
    open var errorForegroundColor: UIColor = defaultErrorForegroundColor
 
    open var errorActiveForegroundColor: UIColor = defaultErrorActiveForegroundColor
    
    open var font: UIFont = UIFont.systemFont(ofSize: defaultFontSize, weight: .regular)
    
    open var showKeyboard: Bool = defaultShowKeyboard
    
    open var addCardPresentationType: PresentationType = defaultAddCardPresentationType
    
    public init() {}
    
}
