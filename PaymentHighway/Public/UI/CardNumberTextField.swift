//
//  CardNumberTextField.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 16/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

open class CardNumberTextField: TextField {
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textFieldIcon = .cardNumber
        placeholder = NSLocalizedString("CreditCardNumber", bundle:  Bundle(for: type(of: self)), comment: "The text shown above the credit card number field")
        format = { (text) in
            let cardBrand = CardData.cardBrand(cardNumber: text.decimalDigits)
            return CardData.format(cardNumber: text, cardBrand: cardBrand)
        }
        validate = { (text) in
            return CardData.isValid(cardNumber: text)
        }
    }
    
}
