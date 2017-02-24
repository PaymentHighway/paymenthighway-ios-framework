//
//  SPHAddCardViewController.swift
//  Clutch
//
//  Created by Atlas Rome on 09/04/15.
//  Copyright (c) 2015 Solinor Oy. All rights reserved.
//

import UIKit

 class SPHAddCardViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var cardNumberLabel: SPHClutchFormLabel!
    @IBOutlet weak var cardExpiryDateLabel: SPHClutchFormLabel!
    @IBOutlet weak var cardSecurityCodeLabel: SPHClutchFormLabel!

    @IBOutlet weak var cardNumberField: SPHClutchCreditCardTextField!
    @IBOutlet weak var cardExpiryDateField: SPHClutchTextField!
    @IBOutlet weak var cardSecurityCodeField: SPHClutchTextField!
    
    @IBOutlet weak var addCardButton: UIButton!
    @IBOutlet weak var navCancel: UIButton!

    @IBOutlet weak var scrollContainer: UIScrollView!

    internal var transactionId = ""
    internal var successHandler : (String) -> () = {print($0)}
    internal var errorHandler : (NSError) -> () = {print($0)}
    
    let correctBorderColor = UIColor(hexInt: 0xa6b9dc).cgColor

    fileprivate var iqKeyboardManagerEnabledCachedValue = false
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.overFullScreen
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        // Override default behavior for popover on small screens
        print(controller.presentedViewController)
        let navcon = controller.presentedViewController as! UINavigationController
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
        visualEffectView.frame = navcon.view.bounds
        navcon.view.insertSubview(visualEffectView, at: 0)
        return navcon
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollContainer.bounces = false
        KeyboardAvoiding.avoidingView = self.scrollContainer

        let clutchBundle = Bundle(for: SPHClutch.self)
        
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
                iconImage = UIImage(named: "cardicon", in: clutchBundle, compatibleWith: nil)
                field?.addTarget(self, action: #selector(SPHAddCardViewController.formatCardNumberFieldOnTheFly(_:)), for: UIControlEvents.editingChanged)
            case cardExpiryDateField?:
                iconImage = UIImage(named: "calendaricon", in: clutchBundle, compatibleWith: nil)
                field?.addTarget(self, action: #selector(SPHAddCardViewController.formatExpirationDateFieldOnTheFly(_:)), for: UIControlEvents.editingChanged)
            case cardSecurityCodeField?:
                iconImage = UIImage(named: "lockicon", in: clutchBundle, compatibleWith: nil)
                field?.addTarget(self, action: #selector(SPHAddCardViewController.formatSecurityCodeFieldOnTheFly(_:)), for: UIControlEvents.editingChanged)
            default: break
            }
    
            iconImageView.image = iconImage
            iconImageView.frame = CGRect(x: 0, y: 0, width: (field?.frame.height)!, height: (field?.frame.height)!)
            iconImageView.contentMode = UIViewContentMode.scaleAspectFit
            field?.addSubview(iconImageView)
        }
        
        // Setup button
        
        let gradientLayer    = CAGradientLayer()
        gradientLayer.frame  = addCardButton.layer.bounds
        gradientLayer.colors = [UIColor(hexInt: 0x4f9ee5).cgColor, UIColor(hexInt: 0x3c89cf).cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = 4.0
        
        addCardButton.layer.cornerRadius = 4.0
        addCardButton.layer.masksToBounds = true
        addCardButton.addTarget(self, action: #selector(SPHAddCardViewController.addCardButtonTapped(_:)), for: .touchUpInside)
        addCardButton.layer.insertSublayer(gradientLayer, at: 0)
        
        // Setup cancel
        
        navCancel.addTarget(self, action: #selector(SPHAddCardViewController.navCancelButtonTapped(_:)),
            for: .touchUpInside)
        
        setupLocalization()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func formatCardNumberFieldOnTheFly(_ textView: AnyObject){
        if let sphField = textView as? SPHClutchTextField{
            sphField.text = SPHClutch.sharedInstance.formattedCardNumber(sphField.text!, cardType: SPHClutch.sharedInstance.cardTypeForCardNumber(SPHClutch.sharedInstance.formattedCardNumberForProcessing(sphField.text!)))
            
            updateCardNumberValidity(sphField)
        }
    }
    
    func formatExpirationDateFieldOnTheFly(_ textView: AnyObject){
        if let sphField = textView as? SPHClutchTextField{
            sphField.text = SPHClutch.sharedInstance.formattedExpirationDate(sphField.text!)
            
            updateExpirationValidity(sphField)
        }
    }
    
    
    func formatSecurityCodeFieldOnTheFly(_ textView: AnyObject){
        if let sphField = textView as? SPHClutchTextField{
            sphField.text = SPHClutch.sharedInstance.formattedSecurityCode(sphField.text!)
            
            updateSecurityCodeValidity(sphField)
        }
    }
    
    func updateCardNumberValidity(_ sphField: SPHClutchTextField)
    {
        genericUpdateCodeValidity(sphField, validityFunction: SPHClutch.sharedInstance.isValidCardNumber)
    }
    
    func updateExpirationValidity(_ sphField: SPHClutchTextField)
    {
        genericUpdateCodeValidity(sphField, validityFunction: SPHClutch.sharedInstance.isValidExpirationDate)
    }
    
    func updateSecurityCodeValidity(_ sphField: SPHClutchTextField)
    {
        genericUpdateCodeValidity(sphField, validityFunction: SPHClutch.sharedInstance.isValidSecurityCode)
    }
    
    func updateAllValidityFields()
    {
        updateCardNumberValidity(cardNumberField)
        updateExpirationValidity(cardExpiryDateField)
        updateSecurityCodeValidity(cardSecurityCodeField)
    }
    
    func allFieldsValid() -> Bool
    {
        return cardNumberField.fieldState == SPHClutchTextFieldState.valid &&
        cardExpiryDateField.fieldState == SPHClutchTextFieldState.valid &&
        cardSecurityCodeField.fieldState == SPHClutchTextFieldState.valid
    }
    
    func genericUpdateCodeValidity(_ sphField: SPHClutchTextField, validityFunction: (String) -> Bool){
        if validityFunction(sphField.text!) == true {
            sphField.fieldState = SPHClutchTextFieldState.valid
        } else {
            sphField.fieldState = SPHClutchTextFieldState.invalid
        }
    }
    
    func setupLocalization() {
        let clutchBundle = Bundle(for: SPHClutch.self)
        cardNumberLabel.text = NSLocalizedString("CreditCardNumber", tableName: nil, bundle: clutchBundle, value: "",comment: "The text shown above the credit card number field")
        cardExpiryDateLabel.text = NSLocalizedString("CreditCardExpiryDate", tableName: nil, bundle: clutchBundle, value: "", comment: "The text shown above the expiry date field")
        cardSecurityCodeLabel.text = NSLocalizedString("CreditCardSecurityCode", tableName: nil, bundle: clutchBundle, value: "", comment: "The text shown above the security code field")
        addCardButton.setTitle(NSLocalizedString("AddCardButtonTitle", tableName: nil, bundle: clutchBundle, value: "", comment: "The text shown on the 'add card' button"), for: UIControlState())
        cardExpiryDateField.placeholder = NSLocalizedString("MM/YY", tableName: nil, bundle: clutchBundle, value: "", comment: "Expiration date placeholder.")

    }
    
    // MARK: UI Events
    
    func navCancelButtonTapped(_ sender: AnyObject) {
        errorHandler(NSError(domain: ClutchDomains.Default , code: 2, userInfo: ["errorReason" : "User tapped cancel on the navbar."]))
        self.dismiss(animated: true, completion: nil)
    }
    
    func addCardButtonTapped(_ sender: AnyObject) {
        if let gradient = self.addCardButton.layer.sublayers!.first as? CAGradientLayer {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .beginFromCurrentState,
                animations: {
                    gradient.colors = [UIColor(hexInt: 0x3c89cf).cgColor, UIColor(hexInt: 0x4f9ee5).cgColor]
                },
                completion: { finished in
                    UIView.animate(withDuration: 0.25, animations: {
                        gradient.colors = [UIColor(hexInt: 0x4f9ee5).cgColor, UIColor(hexInt: 0x3c89cf).cgColor]
                    }) 
                }
            )
        }
        
        updateAllValidityFields()

        if !allFieldsValid() {
            return
        } else {
        
        let month = cardExpiryDateField.text!.components(separatedBy: "/")[0]
        let year = "20" + cardExpiryDateField.text!.components(separatedBy: "/")[1]
        
        SPHClutch.sharedInstance.addCard(transactionId, pan: SPHClutch.sharedInstance.formattedCardNumberForProcessing(cardNumberField.text!), cvc: cardSecurityCodeField.text!, expiryMonth: month, expiryYear: year, success: successHandler, failure: errorHandler)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}
