//
//  Theme.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 31/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

public protocol Theme: class {

    var placeholderAnimationDuration: Double { get set }
    var textFieldRounded: Bool { get set }
    var placeholderFontScale: CGFloat { get set }
    var roundedBorderRadius: CGFloat { get set }
    
    var borderWidth: CGFloat { get set }
    var borderRadius: CGFloat { get }
    
    func borderColor(isValid: Bool, isActive: Bool) -> UIColor
    func placeholderLabelColor(isValid: Bool, isActive: Bool) -> UIColor
    func textColor(isValid: Bool, isActive: Bool) -> UIColor
    func textImageView(textFieldType: TextFieldType, height: CGFloat, cardBrand: CardBrand?) -> UIImageView?
    
    var textImages: [TextFieldType] { get set }
    var textAdjustX: CGFloat { get set }
    
    var primaryBackgroundColor: UIColor { get set }
    var secondaryBackgroundColor: UIColor { get set }

    var primaryForegroundColor: UIColor { get set }
    var primaryActiveForegroundColor: UIColor { get set }
    var secondaryForegroundColor: UIColor { get set }
    var secondaryActiveForegroundColor: UIColor { get set }
    var errorForegroundColor: UIColor { get set }
    var errorActiveForegroundColor: UIColor { get set }
    
    var showKeyboard: Bool { get set }
    
    var addCardPresentationType: PresentationType { get set }
    
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
