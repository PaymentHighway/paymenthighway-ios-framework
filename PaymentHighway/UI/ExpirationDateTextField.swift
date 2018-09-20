//
//  ExpiryDateTextField.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

/// Specialized text field for collecting expiration date.
///
open class ExpiryDateTextField: TextField {

    private var cardExpiryDateDeleting = false

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textFieldType = TextFieldType.expiryDate
        delegate = self
        placeholder = NSLocalizedString("MM/YY", bundle: Bundle(for: type(of: self)), comment: "Expiration date placeholder.")
        format = { [weak self] (text) in
            return ExpiryDate.format(expiryDate: text, deleting: self?.cardExpiryDateDeleting ?? false)
        }
        validate = ExpiryDate.isValid
    }

    open override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let char = string.cString(using: .utf8) {
            let isBackSpace = strcmp(char, "\\b")
            cardExpiryDateDeleting = (isBackSpace == -92) ? true : false
        }
        return super.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
    }
}
