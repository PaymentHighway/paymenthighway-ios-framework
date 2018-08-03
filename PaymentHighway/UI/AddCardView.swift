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
    
    var theme: Theme = DefaultTheme.instance {
        didSet {
            cardNumberTextField.theme = theme
            expirationDateTextField.theme = theme
            securityCodeTextField.theme = theme
            setNeedsDisplay()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = theme.primaryBackgroundColor
        cardNumberTextField.validationDelegate = self
        expirationDateTextField.validationDelegate = self
        securityCodeTextField.validationDelegate = self
        securityCodeTextField.cardBrand = { [weak self] () in CardData.cardBrand(cardNumber: self?.cardNumberTextField.text ?? "")}
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            if theme.showKeyboard {
                // Need to find a better solution detectiong when the view end the animation then becomeFirstResponder should be set
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(20), execute: {
                    self.cardNumberTextField.becomeFirstResponder()
                })
            }
        }
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
        
        func setBecomeFirstResponder(_ textField: TextField) {
            if textField.isValid == false {
                textField.becomeFirstResponder()
            }
        }
        
        switch current {
        case cardNumberTextField:
            setBecomeFirstResponder(expirationDateTextField)
        case expirationDateTextField:
            setBecomeFirstResponder(securityCodeTextField)
        default:
            break
        }
    }
}
