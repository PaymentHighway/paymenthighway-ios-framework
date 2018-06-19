//
//  SPHAddCardViewController.swift
//  PaymentHighway
//
//  Created by Atlas Rome on 09/04/15.
//  Copyright (c) 2015 Payment Highway Oy. All rights reserved.
//

import UIKit

 class SPHAddCardViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var cardNumberLabel: SPHFormLabel!
    @IBOutlet weak var cardExpiryDateLabel: SPHFormLabel!
    @IBOutlet weak var cardSecurityCodeLabel: SPHFormLabel!

    @IBOutlet weak var cardNumberField: SPHCreditCardTextField!
    @IBOutlet weak var cardExpiryDateField: SPHTextField!
    @IBOutlet weak var cardSecurityCodeField: SPHTextField!
    
    @IBOutlet weak var addCardButton: UIButton!
    @IBOutlet weak var navCancel: UIButton!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topContentConstraint: NSLayoutConstraint!
    
    private var visualEffectView: UIView!
    private var buttonGradientLayer:CAGradientLayer = {
        let gradientLayer  = CAGradientLayer()
        gradientLayer.colors = [UIColor(hexInt: 0x4f9ee5).cgColor, UIColor(hexInt: 0x3c89cf).cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = 4.0
        return gradientLayer
    }()
    
    internal var transactionId = ""
    internal var successHandler : (String) -> () = {print($0)}
    internal var errorHandler : (NSError) -> () = {print($0)}
    
    private let correctBorderColor = UIColor(hexInt: 0xa6b9dc).cgColor
    private let scrollContentHeight:CGFloat = 330
    
    private var cardExpiryDateDeleting = false
    
    fileprivate var iqKeyboardManagerEnabledCachedValue = false
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.overFullScreen
    }
    
    func presentationController(_ controller: UIPresentationController,
                                viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        // Override default behavior for popover on small screens
        guard let navcon = controller.presentedViewController as? UINavigationController else { return nil }
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
        navcon.view.insertSubview(visualEffectView, at: 0)
        return navcon
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let char = string.cString(using: .utf8) { 
	        let isBackSpace = strcmp(char, "\\b")
	        cardExpiryDateDeleting = (isBackSpace == -92) ? true : false
        }
        return true
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.bounces = false

        let bundle = Bundle(for: SPH.self)
        
        // Setup text field
        for field in [cardNumberField, cardExpiryDateField, cardSecurityCodeField] {
            field?.backgroundColor = UIColor.white
            field?.layer.borderColor  = correctBorderColor
            field?.layer.borderWidth  = 1.5
            field?.layer.cornerRadius = 2.0
            field?.inset = Inset(44, 0)
            
            field?.keyboardType = UIKeyboardType.numberPad
            
            var iconImage: UIImage? = nil
            let iconImageView = UIImageView(frame: CGRect.zero)
            
            switch field {
            case cardNumberField?:
                iconImage = UIImage(named: "cardicon", in: bundle, compatibleWith: nil)
                field?.addTarget(self, action: #selector(SPHAddCardViewController.formatCardNumberFieldOnTheFly(_:)), for: UIControlEvents.editingChanged)
            case cardExpiryDateField?:
                iconImage = UIImage(named: "calendaricon", in: bundle, compatibleWith: nil)
                field?.addTarget(self, action: #selector(SPHAddCardViewController.formatExpirationDateFieldOnTheFly(_:)), for: UIControlEvents.editingChanged)
            case cardSecurityCodeField?:
                iconImage = UIImage(named: "lockicon", in: bundle, compatibleWith: nil)
                field?.addTarget(self, action: #selector(SPHAddCardViewController.formatSecurityCodeFieldOnTheFly(_:)), for: UIControlEvents.editingChanged)
            default: break
            }
    
            iconImageView.image = iconImage
            iconImageView.frame = CGRect(x: 0, y: 0, width: (field?.frame.height)!, height: (field?.frame.height)!)
            iconImageView.contentMode = UIViewContentMode.scaleAspectFit
            field?.addSubview(iconImageView)
        }
        
        // Setup button
        addCardButton.layer.cornerRadius = 4.0
        addCardButton.layer.masksToBounds = true
        addCardButton.addTarget(self, action: #selector(SPHAddCardViewController.addCardButtonTapped(_:)), for: .touchUpInside)
        addCardButton.layer.insertSublayer(buttonGradientLayer, at: 0)
        
        // Setup cancel
        
        navCancel.addTarget(self, action: #selector(SPHAddCardViewController.navCancelButtonTapped(_:)),
            for: .touchUpInside)
        
        setupLocalization()
        
        // cardExpiryDateField need to detect if is deleting
        
        cardExpiryDateField.delegate = self
        
        // Keyboard notifications
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(SPHAddCardViewController.keyboardWillChangeFrame(_:)),
                                       name: .UIKeyboardWillChangeFrame,
                                       object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        visualEffectView.frame = view.bounds
        buttonGradientLayer.frame  = addCardButton.layer.bounds
        
        // adjust scrollView's contect size such that the input can be moved up when the keyboard shows
        topContentConstraint.constant = scrollView.frame.height - scrollContentHeight
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.contentOffset.y = keyboardHeight
        
    }
    
    @objc func formatCardNumberFieldOnTheFly(_ textView: AnyObject) {
        if let sphField = textView as? SPHTextField, let text = sphField.text {
            let cardType = SPH.sharedInstance.cardTypeForCardNumber(SPH.sharedInstance.formattedCardNumberForProcessing(text))
            sphField.text = SPH.sharedInstance.formattedCardNumber(text, cardType: cardType)
            updateCardNumberValidity(sphField)
        }
    }
    
    @objc func formatExpirationDateFieldOnTheFly(_ textView: AnyObject) {
        if let sphField = textView as? SPHTextField, let text = sphField.text {
            sphField.text = SPH.sharedInstance.formattedExpirationDate(text, cardExpiryDateDeleting)
            updateExpirationValidity(sphField)
        }
    }
    
    @objc func formatSecurityCodeFieldOnTheFly(_ textView: AnyObject) {
        if let sphField = textView as? SPHTextField {
            sphField.text = SPH.sharedInstance.formattedSecurityCode(sphField.text!)
            
            updateSecurityCodeValidity(sphField)
        }
    }
    
    func updateCardNumberValidity(_ sphField: SPHTextField) {
        genericUpdateCodeValidity(sphField, validityFunction: SPH.sharedInstance.isValidCardNumber)
    }
    
    func updateExpirationValidity(_ sphField: SPHTextField) {
        genericUpdateCodeValidity(sphField, validityFunction: SPH.sharedInstance.isValidExpirationDate)
    }
    
    func updateSecurityCodeValidity(_ sphField: SPHTextField) {
        genericUpdateCodeValidity(sphField, validityFunction: SPH.sharedInstance.isValidSecurityCode)
    }
    
    func updateAllValidityFields(){
        updateCardNumberValidity(cardNumberField)
        updateExpirationValidity(cardExpiryDateField)
        updateSecurityCodeValidity(cardSecurityCodeField)
    }
    
    func allFieldsValid() -> Bool {
        return cardNumberField.fieldState == SPHTextFieldState.valid &&
               cardExpiryDateField.fieldState == SPHTextFieldState.valid &&
               cardSecurityCodeField.fieldState == SPHTextFieldState.valid
    }
    
    func genericUpdateCodeValidity(_ sphField: SPHTextField, validityFunction: (String) -> Bool) {
        if validityFunction(sphField.text!) == true {
            sphField.fieldState = SPHTextFieldState.valid
        } else {
            sphField.fieldState = SPHTextFieldState.invalid
        }
    }
    
    func setupLocalization() {
        let bundle = Bundle(for: SPH.self)
        cardNumberLabel.text = NSLocalizedString("CreditCardNumber", bundle: bundle, comment: "The text shown above the credit card number field")
        cardExpiryDateLabel.text = NSLocalizedString("CreditCardExpiryDate", bundle: bundle, comment: "The text shown above the expiry date field")
        cardSecurityCodeLabel.text = NSLocalizedString("CreditCardSecurityCode", bundle: bundle, comment: "The text shown above the security code field")
        let title = NSLocalizedString("AddCardButtonTitle", bundle: bundle, comment: "The text shown on the 'add card' button")
        addCardButton.setTitle(title, for: UIControlState())
        cardExpiryDateField.placeholder = NSLocalizedString("MM/YY", bundle: bundle, comment: "Expiration date placeholder.")
    }
    
    // MARK: UI Events
    
    @objc func navCancelButtonTapped(_ sender: AnyObject) {
        errorHandler(NSError(domain: PaymentHighwayDomains.Default, code: 2, userInfo: ["errorReason" : "User tapped cancel on the navbar."]))
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func addCardButtonTapped(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .beginFromCurrentState,
            animations: {
                self.buttonGradientLayer.colors = [UIColor(hexInt: 0x3c89cf).cgColor, UIColor(hexInt: 0x4f9ee5).cgColor]
            },
            completion: { _ in
                UIView.animate(withDuration: 0.25, animations: {
                    self.buttonGradientLayer.colors = [UIColor(hexInt: 0x4f9ee5).cgColor, UIColor(hexInt: 0x3c89cf).cgColor]
                }) 
            }
        )
        
        updateAllValidityFields()

        if !allFieldsValid() {
            return
        } else {
            let month = cardExpiryDateField.text!.components(separatedBy: "/")[0]
            let year = "20" + cardExpiryDateField.text!.components(separatedBy: "/")[1]
            
            SPH.sharedInstance.addCard(transactionId,
                                       pan: SPH.sharedInstance.formattedCardNumberForProcessing(cardNumberField.text!),
                                       cvc: cardSecurityCodeField.text!,
                                       expiryMonth: month,
                                       expiryYear: year,
                                       success: successHandler,
                                       failure: errorHandler)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Keyboard Notification Actions
    
    private var keyboardHeight: CGFloat = 0 {
        didSet(oldHeight) {
            if keyboardHeight != oldHeight {
                view.setNeedsLayout()
            }
        }
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        keyboardHeight = max(view.superview!.frame.maxY - keyboardFrame.minY, 0)
        self.view.layoutIfNeeded()
    }
}
