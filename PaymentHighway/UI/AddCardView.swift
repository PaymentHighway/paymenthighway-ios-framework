//
//  AddCardView.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import UIKit

class AddCardView: UIView, ValidationDelegate {
    
    let nibName = "AddCardView"
    var contentView: UIView?
    
    @IBOutlet weak var cardNumberTextField: CardNumberTextField!
    @IBOutlet weak var expiryDateTextField: ExpiryDateTextField!
    @IBOutlet weak var securityCodeTextField: SecurityCodeTextField!

    weak var validationDelegate: ValidationDelegate?
    
    var card: CardData? {
        guard let pan = cardNumberTextField.text,
              let cvc = securityCodeTextField.text,
              let expiryDateString =  expiryDateTextField.text,
            let expiryDate = ExpiryDate(expiryDate: expiryDateString) else { return nil }
        return CardData(pan: pan, cvc: cvc, expiryDate: expiryDate)
    }
    
    var theme: Theme = DefaultTheme.instance {
        didSet {
            setTheme()
            setNeedsDisplay()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cardNumberTextField.validationDelegate = self
        expiryDateTextField.validationDelegate = self
        securityCodeTextField.validationDelegate = self
        securityCodeTextField.cardBrand = { [weak self] () in CardBrand(cardNumber: self?.cardNumberTextField.text ?? "")}
        setTheme()
    }
    
    private func setTheme() {
        contentView?.backgroundColor = theme.primaryBackgroundColor
        backgroundColor = theme.primaryBackgroundColor
        cardNumberTextField.theme = theme
        expiryDateTextField.theme = theme
        securityCodeTextField.theme = theme
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
               expiryDateTextField.isValid &&
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
            setBecomeFirstResponder(expiryDateTextField)
        case expiryDateTextField:
            if !theme.expiryDatePicker {
                if cardNumberTextField.isValid {
                    setBecomeFirstResponder(securityCodeTextField)
                } else {
                    setBecomeFirstResponder(cardNumberTextField)
                }
            }
        default:
            break
        }
    }
}
