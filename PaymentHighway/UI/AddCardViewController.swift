//
//  AddCardViewController.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import UIKit

public protocol AddCardDelegate: class {
    func cancel()
    func addCard(_ card: CardData)
}

/// View controller to manage a credit card entry.
/// It renders a 'Cancel' and 'Add card' buttons so it must be presented inside a `UINavigationController`.
///
/// `Presenter` helper can be used to show the View Controller.
///
/// User can fill out the form and on submission card data will be provided to addCard delegate.
/// User can cancel the form and proper delegate call is performed.
///
public class AddCardViewController: UIViewController, ValidationDelegate {
    
    @IBOutlet var addCardView: AddCardView!
    
    var addCardButton: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    
    var theme: Theme {
        didSet {
            addCardView?.theme = theme
        }
    }
    
    /// The add card delegate
    public weak var addCardDelegate: AddCardDelegate?
    
    /// Initializes a new `AddCardViewController` with thecprovided theme.
    ///
    public init(theme: Theme = DefaultTheme.instance) {
        self.theme = theme
        super.init(nibName: "AddCardView", bundle: Bundle(for: type(of: self)))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(AddCardViewController.cancelPressed(_:)))
        cancelButton.setTitleTextAttributes([.foregroundColor: theme.highlightColor], for: .normal)
        cancelButton.setTitleTextAttributes([.foregroundColor: theme.highlightDisableColor], for: .disabled)
        navigationItem.leftBarButtonItem = cancelButton

        handleRightBarButton(spinner: false)
       
        addCardView.validationDelegate = self
        addCardView?.theme = theme

        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = theme.barTintColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: theme.primaryForegroundColor, .font: theme.emphasisFont]
    }
    
    public func isValidDidChange(_ isValid: Bool, _ textField: TextField?) {
        self.addCardButton.isEnabled = isValid
    }
    
    public func showError(message: String) {
        enableUserInput(enabled: true)
        addCardView.showError(message: message)
    }
    
    @objc func cancelPressed(_ sender: UIBarButtonItem) {
        finish()
    }
    
    @objc func addCardPressed(_ sender: Any) {
        if let pan = addCardView.cardNumberTextField.text,
           let cvc = addCardView.securityCodeTextField.text,
           let expiryDateString =  addCardView.expiryDateTextField.text,
           let expiryDate = ExpiryDate(expiryDate:expiryDateString) {
            let card = CardData(pan: pan, cvc: cvc, expiryDate: expiryDate)
            finish(card)
        }
    }
    
    private func enableUserInput(enabled: Bool) {
        handleRightBarButton(spinner: !enabled)
        addCardView.isUserInteractionEnabled = enabled
        cancelButton.isEnabled = enabled
    }
    
    private func finish(_ card: CardData? = nil) {
        if let card = card {
            enableUserInput(enabled: false)
            addCardDelegate?.addCard(card)
        } else {
            addCardDelegate?.cancel()
        }
        addCardView.endEditing(true)
    }
    
    private func handleRightBarButton(spinner: Bool = false) {
        navigationItem.rightBarButtonItem = nil
        if spinner == false {
            let addCardButtonTitle = NSLocalizedString("AddCardButtonTitle",
                                                       bundle: Bundle(for: type(of: self)),
                                                       comment: "The text shown on the 'add card' button")
            addCardButton = UIBarButtonItem(title: addCardButtonTitle,
                                            style: .plain,
                                            target: self,
                                            action: #selector(AddCardViewController.addCardPressed(_:)))
            addCardButton.isEnabled = addCardView.isValid
            addCardButton.setTitleTextAttributes([.foregroundColor: theme.highlightColor], for: .normal)
            addCardButton.setTitleTextAttributes([.foregroundColor: theme.highlightDisableColor], for: .disabled)

        } else {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicator.hidesWhenStopped = false
            activityIndicator.startAnimating()
            addCardButton = UIBarButtonItem(customView: activityIndicator)
        }
        navigationItem.rightBarButtonItem = addCardButton
    }
}
