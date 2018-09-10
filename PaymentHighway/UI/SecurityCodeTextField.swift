//
//  SecurityCodeTextField.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

/// Specialized text field for collecting security code.
///
open class SecurityCodeTextField: TextField {
    
    var cardBrand: () -> CardBrand? = { () in return nil }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textFieldType = .securityCode
        placeholder = NSLocalizedString("CreditCardSecurityCode", bundle: Bundle(for: type(of: self)), comment: "The text shown above the security code field")
        format = { [weak self] (text) in
            return CardData.format(securityCode: text, cardBrand: self?.cardBrand())
        }
        validate = { [weak self] (text) in
            return CardData.isValid(securityCode: text, cardBrand: self?.cardBrand())
        }
    }
}
