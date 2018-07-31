//
//  SecurityCodeTextField.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 16/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

open class SecurityCodeTextField: TextField {
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textFieldIcon = .securityCode
        placeholder = NSLocalizedString("CreditCardSecurityCode", bundle: Bundle(for: type(of: self)), comment: "The text shown above the security code field")
        format = { (text) in
            return CardData.format(securityCode: text)
        }
        validate = { (text) in
            return CardData.isValid(securityCode: text)
        }
    }
}
