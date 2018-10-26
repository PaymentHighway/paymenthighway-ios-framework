//
//  DarkTheme.swift
//  PaymentHighwayDemo
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import PaymentHighway

extension TextFieldType {
    func iconId(cardBrand: CardBrand?) -> String {
        switch self {
        case .cardNumber: return "ccnumDark"
        case .expiryDate: return "dateDark"
        case .securityCode: return "lockDark"
        }
    }
}

class DarkTheme: DefaultTheme {
    override init() {
        super.init()
        barTintColor = UIColor.black
        primaryBackgroundColor = UIColor.black
        secondaryBackgroundColor = UIColor.black
        primaryForegroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 203)
        primaryActiveForegroundColor = UIColor.white
        secondaryForegroundColor = UIColor(hexInt: 0xd261e7)
        secondaryActiveForegroundColor = secondaryForegroundColor
        highlightDisableColor = UIColor(red: 155, green: 155, blue: 155)
    }
    
    override func textImageView(textFieldType: TextFieldType, cardBrand: CardBrand? = nil) -> UIView? {
        let iconImageView = UIImageView(frame: CGRect.zero)
        iconImageView.image = UIImage(named: textFieldType.iconId(cardBrand: cardBrand),
                                      in: Bundle(for: type(of: self)),
                                      compatibleWith: nil)
        iconImageView.frame = CGRect(x: 0, y: 0, width: textImageHeight, height: textImageHeight)
        iconImageView.contentMode = UIViewContentMode.scaleAspectFit
        return iconImageView
    }
}
