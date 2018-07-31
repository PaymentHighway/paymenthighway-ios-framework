//
//  AddCardView.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 24/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import UIKit

@IBDesignable class AddCardView: UIView, TextFieldValidationDelegate {
    
    @IBOutlet weak var cardNumberTextField: CardNumberTextField!
    @IBOutlet weak var expirationDateTextField: ExpirationDateTextField!
    @IBOutlet weak var securityCodeTextField: SecurityCodeTextField!
    
    weak var validationDelegate: TextFieldValidationDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cardNumberTextField.validationDelegate = self
        expirationDateTextField.validationDelegate = self
        securityCodeTextField.validationDelegate = self
        // ATM disabled. Need to find a solution how to show powered by ...
        // that would be covered from the keyboard
        // cardNumberTextField.becomeFirstResponder()
    }
    
    var isValid: Bool {
        return cardNumberTextField.isValid &&
               expirationDateTextField.isValid &&
               securityCodeTextField.isValid
    }
    
    func isValidDidChange(_ isValid: Bool, _ textField: TextField?) {
        validationDelegate?.isValidDidChange(self.isValid, nil)
        if isValid,
           let currentTextField = textField {
            moveToNextInvalid(current: currentTextField)
        }
    }
    
    private func moveToNextInvalid(current: TextField) {
        
        func runBecomeFirstResponder(_ textField: TextField) {
            if textField.isValid == false {
                textField.becomeFirstResponder()
            }
        }
        
        switch current {
        case cardNumberTextField:
            runBecomeFirstResponder(expirationDateTextField)
        case expirationDateTextField:
            runBecomeFirstResponder(securityCodeTextField)
        default:
            break
        }
    }
}
