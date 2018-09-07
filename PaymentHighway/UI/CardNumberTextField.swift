//
//  CardNumberTextField.swift
//  PaymentHighway
//
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
            return CardData.format(cardNumber: text)
        }
        validate = { (text) in  
            return CardData.isValid(cardNumber: text)
        }
    }
    
}
