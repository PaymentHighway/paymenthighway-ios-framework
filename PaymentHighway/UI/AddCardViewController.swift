//
//  AddCardViewController.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import UIKit

public protocol AddCardDelegate: class {
    func addCardCancelled()
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
public class AddCardViewController: BaseViewController, ValidationDelegate {
    
    @IBOutlet weak var addCardView: AddCardView!
    
    /// The add card delegate
    public weak var addCardDelegate: AddCardDelegate?
    
    /// Initializes a new `AddCardViewController` with thecprovided theme.
    ///
    public init(theme: Theme = DefaultTheme.instance) {
        let okButtonLabel = NSLocalizedString("AddCardButtonTitle",
                                                   bundle: Bundle(for: type(of: self)),
                                                   comment: "The text shown on the 'add card' button")
        super.init(theme: theme, nibName: "AddCardViewController", okButtonLabel: okButtonLabel)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = theme.primaryBackgroundColor
        addCardView.validationDelegate = self
        addCardView?.theme = theme
        themeDidSet = {
            self.addCardView.theme = self.theme
        }
    }
    
    public func isValidDidChange(_ isValid: Bool, _ textField: TextField?) {
        self.okButton.isEnabled = isValid
    }
    
    public override func showToast(message: String, completion: (() -> Void)? = nil) {
        super.showToast(message: message) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.enableUserInput(enabled: true, okButtonEnabled: strongSelf.addCardView.isValid)
            completion?()
        }
   }
    
    @objc override func cancelPressed(_ sender: Any) {
        finish()
    }
    
    @objc override func okPressed(_ sender: Any) {
        if let card = addCardView.card {
            finish(card)
        }
    }
    
    private func finish(_ card: CardData? = nil) {
        if let card = card {
            enableUserInput(enabled: false, okButtonEnabled: addCardView.isValid)
            addCardDelegate?.addCard(card)
        } else {
            addCardDelegate?.addCardCancelled()
        }
        addCardView.endEditing(true)
    }
    
}
