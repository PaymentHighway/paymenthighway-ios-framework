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
    internal var successHandler : (String) -> () = {println($0)}
    internal var errorHandler : (NSError) -> () = {println($0)}
    
    let correctBorderColor = UIColor(hexInt: 0xa6b9dc).CGColor

    private var iqKeyboardManagerEnabledCachedValue = false
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.OverFullScreen
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        // Override default behavior for popover on small screens
        println(controller.presentedViewController)
        let navcon = controller.presentedViewController as! UINavigationController
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        visualEffectView.frame = navcon.view.bounds
        navcon.view.insertSubview(visualEffectView, atIndex: 0)
        return navcon
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollContainer.bounces = false

        let clutchBundle = NSBundle(forClass: SPHClutch.self)
        
        // Setup text field
        for field in [cardNumberField, cardExpiryDateField, cardSecurityCodeField] {
            field.backgroundColor = UIColor.whiteColor()
            field.layer.borderColor  = correctBorderColor
            field.layer.borderWidth  = 1.5
            field.layer.cornerRadius = 2.0
            field.inset = Inset(44, 0)
            
            field.keyboardType = UIKeyboardType.NumberPad
            
            
            var iconImage: UIImage? = nil
            let iconImageView = UIImageView(frame: CGRectZero)
            
            switch field {
            case cardNumberField:
                iconImage = UIImage(named: "cardicon", inBundle: clutchBundle, compatibleWithTraitCollection: nil)
                field.addTarget(self, action: "formatCardNumberFieldOnTheFly:", forControlEvents: UIControlEvents.EditingChanged)
            case cardExpiryDateField:
                iconImage = UIImage(named: "calendaricon", inBundle: clutchBundle, compatibleWithTraitCollection: nil)
                field.addTarget(self, action: "formatExpirationDateFieldOnTheFly:", forControlEvents: UIControlEvents.EditingChanged)
            case cardSecurityCodeField:
                iconImage = UIImage(named: "lockicon", inBundle: clutchBundle, compatibleWithTraitCollection: nil)
                field.addTarget(self, action: "formatSecurityCodeFieldOnTheFly:", forControlEvents: UIControlEvents.EditingChanged)
            default: break
            }
    
            iconImageView.image = iconImage
            iconImageView.frame = CGRectMake(0, 0, field.frame.height, field.frame.height)
            iconImageView.contentMode = UIViewContentMode.ScaleAspectFit
            field.addSubview(iconImageView)
        }
        
        // Setup button
        
        let gradientLayer    = CAGradientLayer()
        gradientLayer.frame  = addCardButton.layer.bounds
        gradientLayer.colors = [UIColor(hexInt: 0x4f9ee5).CGColor, UIColor(hexInt: 0x3c89cf).CGColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = 4.0
        
        addCardButton.layer.cornerRadius = 4.0
        addCardButton.layer.masksToBounds = true
        addCardButton.addTarget(self, action: "addCardButtonTapped:", forControlEvents: .TouchUpInside)
        addCardButton.layer.insertSublayer(gradientLayer, atIndex: 0)
        
        // Setup cancel
        
        navCancel.addTarget(self, action: "navCancelButtonTapped:",
            forControlEvents: .TouchUpInside)
        
        setupLocalization()
    }

    override func  viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        iqKeyboardManagerEnabledCachedValue = IQKeyboardManager.sharedManager().enable
        IQKeyboardManager.sharedManager().enable = true
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.sharedManager().enable = iqKeyboardManagerEnabledCachedValue
    }
    
    func formatCardNumberFieldOnTheFly(textView: AnyObject){
        if let sphField = textView as? SPHClutchTextField{
            sphField.text = SPHClutch.sharedInstance.formattedCardNumber(sphField.text, cardType: SPHClutch.sharedInstance.cardTypeForCardNumber(SPHClutch.sharedInstance.formattedCardNumberForProcessing(sphField.text)))
            
            updateCardNumberValidity(sphField)
        }
    }
    
    func formatExpirationDateFieldOnTheFly(textView: AnyObject){
        if let sphField = textView as? SPHClutchTextField{
            sphField.text = SPHClutch.sharedInstance.formattedExpirationDate(sphField.text)
            
            updateExpirationValidity(sphField)
        }
    }
    
    
    func formatSecurityCodeFieldOnTheFly(textView: AnyObject){
        if let sphField = textView as? SPHClutchTextField{
            sphField.text = SPHClutch.sharedInstance.formattedSecurityCode(sphField.text)
            
            updateSecurityCodeValidity(sphField)
        }
    }
    
    func updateCardNumberValidity(sphField: SPHClutchTextField)
    {
        genericUpdateCodeValidity(sphField, validityFunction: SPHClutch.sharedInstance.isValidCardNumber)
    }
    
    func updateExpirationValidity(sphField: SPHClutchTextField)
    {
        genericUpdateCodeValidity(sphField, validityFunction: SPHClutch.sharedInstance.isValidExpirationDate)
    }
    
    func updateSecurityCodeValidity(sphField: SPHClutchTextField)
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
        return cardNumberField.fieldState == SPHClutchTextFieldState.Valid &&
        cardExpiryDateField.fieldState == SPHClutchTextFieldState.Valid &&
        cardSecurityCodeField.fieldState == SPHClutchTextFieldState.Valid
    }
    
    func genericUpdateCodeValidity(sphField: SPHClutchTextField, validityFunction: (String) -> Bool){
        if validityFunction(sphField.text) == true {
            sphField.fieldState = SPHClutchTextFieldState.Valid
        } else {
            sphField.fieldState = SPHClutchTextFieldState.Invalid
        }
    }
    
    func setupLocalization() {
        let clutchBundle = NSBundle(forClass: SPHClutch.self)
        cardNumberLabel.text = NSLocalizedString("CreditCardNumber", tableName: nil, bundle: clutchBundle, value: "",comment: "The text shown above the credit card number field")
        cardExpiryDateLabel.text = NSLocalizedString("CreditCardExpiryDate", tableName: nil, bundle: clutchBundle, value: "", comment: "The text shown above the expiry date field")
        cardSecurityCodeLabel.text = NSLocalizedString("CreditCardSecurityCode", tableName: nil, bundle: clutchBundle, value: "", comment: "The text shown above the security code field")
        addCardButton.setTitle(NSLocalizedString("AddCardButtonTitle", tableName: nil, bundle: clutchBundle, value: "", comment: "The text shown on the 'add card' button"), forState: .Normal)
        cardExpiryDateField.placeholder = NSLocalizedString("MM/YY", tableName: nil, bundle: clutchBundle, value: "", comment: "Expiration date placeholder.")

    }
    
    // MARK: UI Events
    
    func navCancelButtonTapped(sender: AnyObject) {
        errorHandler(NSError(domain: ClutchDomains.Default , code: 2, userInfo: ["errorReason" : "User tapped cancel on the navbar."]))
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addCardButtonTapped(sender: AnyObject) {
        if let gradient = self.addCardButton.layer.sublayers.first as? CAGradientLayer {
            UIView.animateWithDuration(0.25, delay: 0.0, options: .BeginFromCurrentState,
                animations: {
                    gradient.colors = [UIColor(hexInt: 0x3c89cf).CGColor, UIColor(hexInt: 0x4f9ee5).CGColor]
                },
                completion: { finished in
                    UIView.animateWithDuration(0.25) {
                        gradient.colors = [UIColor(hexInt: 0x4f9ee5).CGColor, UIColor(hexInt: 0x3c89cf).CGColor]
                    }
                }
            )
        }
        
        updateAllValidityFields()

        if !allFieldsValid() {
            return
        } else {
        
        let month = cardExpiryDateField.text.componentsSeparatedByString("/")[0]
        let year = "20" + cardExpiryDateField.text.componentsSeparatedByString("/")[1]
        
        SPHClutch.sharedInstance.addCard(transactionId, pan: SPHClutch.sharedInstance.formattedCardNumberForProcessing(cardNumberField.text), cvc: cardSecurityCodeField.text, expiryMonth: month, expiryYear: year, success: successHandler, failure: errorHandler)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
