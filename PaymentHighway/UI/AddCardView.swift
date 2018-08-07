//
//  AddCardView.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 24/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import UIKit

private let showErrorAnimation = 0.8
private let delayHidingError = 800

class AddCardView: UIView, TextFieldValidationDelegate {
    
    @IBOutlet weak var cardNumberTextField: CardNumberTextField!
    @IBOutlet weak var expirationDateTextField: ExpirationDateTextField!
    @IBOutlet weak var securityCodeTextField: SecurityCodeTextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var topLabelConstraint: NSLayoutConstraint!

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
        errorLabel.alpha = 0
        errorLabel.font = theme.font
        // Invert the color of the normal error in the normal ui element
        errorLabel.backgroundColor = theme.errorForegroundColor
        errorLabel.textColor = theme.secondaryBackgroundColor
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            if theme.showKeyboard {
                // Need to find a better solution to detect when the view end the animation then becomeFirstResponder should be set
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
    
    func showError(message: String) {
        self.errorLabel.text = message
        UIView.animate(withDuration: showErrorAnimation, delay: 0.0, options: .curveEaseOut,
                       animations: {
                           self.errorLabel.alpha = 1.0
                           self.topLabelConstraint.constant = 0
                       },
                       completion: { _ in
                           self.hideError()
                       })
    }
    
    private func hideError() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(delayHidingError), execute: {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState],
                           animations: {
                               self.errorLabel.alpha = 0
                           },
                           completion: { _ in
                               self.topLabelConstraint.constant = -(self.errorLabel.bounds.height)
                           })
        })
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
            if cardNumberTextField.isValid {
                setBecomeFirstResponder(securityCodeTextField)
            } else {
                setBecomeFirstResponder(cardNumberTextField)
            }
        default:
            break
        }
    }
}
