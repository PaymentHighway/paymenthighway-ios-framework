//
//  AddCardViewController.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 28/06/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import UIKit

public protocol AddCardDelegate: class {
    func cancel()
    func addCard(_ card: CardData)
}

public class AddCardViewController: UIViewController, TextFieldValidationDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet var addCardView: AddCardView!
    
    var addCardButton: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    
    weak var addCardDelegate: AddCardDelegate?
    
    public init() {
        super.init(nibName: "AddCardView", bundle: Bundle(for: type(of: self)))
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(AddCardViewController.cancelPressed(_:)))
        navigationItem.leftBarButtonItem = cancelButton
        
        let addCardButtonTitle = NSLocalizedString("AddCardButtonTitle",
                                                   bundle: Bundle(for: type(of: self)),
                                                   comment: "The text shown on the 'add card' button")
        addCardButton = UIBarButtonItem(title: addCardButtonTitle, style: .plain, target: self, action: #selector(AddCardViewController.addCardPressed(_:)))
        navigationItem.rightBarButtonItem = addCardButton
        addCardButton.isEnabled = false
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        addCardView.validationDelegate = self
    }
    
    func isValidDidChange(_ isValid: Bool, _ textField: TextField?) {
        self.addCardButton.isEnabled = isValid
    }
    
    @objc func cancelPressed(_ sender: UIBarButtonItem) {
        finish()
    }
    
    @objc func addCardPressed(_ sender: Any) {
        if let pan = addCardView.cardNumberTextField.text,
           let cvc = addCardView.securityCodeTextField.text,
           let expirationDateString =  addCardView.expirationDateTextField.text,
           let expirationDate = ExpirationDate(expirationDate:expirationDateString) {
            let card = CardData(pan: pan, cvc: cvc, expirationDate: expirationDate)
            finish(card)
        }
    }
    
    private func finish(_ card: CardData? = nil) {
        if let card = card {
            addCardDelegate?.addCard(card)
        } else {
            addCardDelegate?.cancel()
        }
        addCardView.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
}
