//
//  CardNumberTextField.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 16/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

/// Specialized text field for collecting credit number.
///
open class CardNumberTextField: TextField {
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textFieldType = .cardNumber
        placeholder = NSLocalizedString("CreditCardNumber", bundle:  Bundle(for: type(of: self)), comment: "The text shown above the credit card number field")
        format = { (text) in
            let cardBrand = CardData.cardBrand(cardNumber: text)
            return CardData.format(cardNumber: text, cardBrand: cardBrand)
        }
        validate = { (text) in
            if CardData.cardBrand(cardNumber: text) != nil {
                return true
            }
            return false
        }
    }
    
}
