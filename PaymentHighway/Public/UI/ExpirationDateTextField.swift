//
//  ExpirationDateTextField.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 16/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

open class ExpirationDateTextField: TextField, UITextFieldDelegate {

    private var cardExpiryDateDeleting = false

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textFieldIcon = .expirationDate
        delegate = self
        placeholder = NSLocalizedString("MM/YY", bundle: Bundle(for: type(of: self)), comment: "Expiration date placeholder.")
        format = { [weak self] (text) in
            return ExpirationDate.format(expirationDate: text, deleting: self?.cardExpiryDateDeleting ?? false)
        }
        validate = ExpirationDate.isValid
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let char = string.cString(using: .utf8) {
            let isBackSpace = strcmp(char, "\\b")
            cardExpiryDateDeleting = (isBackSpace == -92) ? true : false
        }
        return true
    }
}
