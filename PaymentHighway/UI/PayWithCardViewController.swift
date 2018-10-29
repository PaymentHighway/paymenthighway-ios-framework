//
//  PayWithCardViewController.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import UIKit

public protocol PayWithCardDelegate: class {
    func paymentCancelled()
    func executePayment(purchase: Purchase, card: CardData)
}

private let scaleForSumLabelFont: CGFloat = 2.2
private let scaleForPurchaseDescriptionLabelFont: CGFloat = 1.8
private let scaleForInfoLabelFont: CGFloat = 1.2

/// View controller to manage a credit card entry for a specific purchase
/// It renders a 'Cancel' and 'Pay' buttons so it must be presented inside a `UINavigationController`.
///
/// `Presenter` helper can be used to show the View Controller.
///
/// User can fill out the form and on submission card data will be provided to payWithCard delegate.
/// User can cancel the form and proper delegate call is performed.
///
public class PayWithCardViewController: BaseViewController, ValidationDelegate {
    
    @IBOutlet weak var addCardView: AddCardView!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var purchaseDescription: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    private let purchase: Purchase
    
    /// The pay with card delegate
    public weak var payWithCardDelegate: PayWithCardDelegate?
    
    /// Initializes a new `PayWithCardViewController` with the provided purchase and theme.
    ///
    public init(purchase: Purchase, theme: Theme = DefaultTheme.instance) {
        self.purchase = purchase
        let okButtonLabel = NSLocalizedString("PayWithCardButtonTitle",
                                              bundle: Bundle(for: type(of: self)),
                                              comment: "The text shown on the 'pay with card' button")
        super.init(theme: theme, nibName: "PayWithCardView", okButtonLabel: okButtonLabel)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        addCardView.validationDelegate = self
        addCardView?.theme = theme
        themeDidSet = {
            self.addCardView.theme = self.theme
        }
        let infoText = NSLocalizedString("PayWithCardInfo",
                                        bundle: Bundle(for: type(of: self)),
                                        comment: "Please fill in the information on your card")
        theme.setTheme(sumLabel,
                       text: purchase.amountWithCurrency,
                       isEmphasisFont: true,
                       fontScale: scaleForSumLabelFont)
        theme.setTheme(purchaseDescription,
                       text: purchase.description,
                       fontScale: scaleForPurchaseDescriptionLabelFont)
        theme.setTheme(infoLabel, text: infoText, fontScale: scaleForInfoLabelFont)
        view.backgroundColor = theme.primaryBackgroundColor
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
            payWithCardDelegate?.executePayment(purchase: purchase, card: card)
        } else {
            payWithCardDelegate?.paymentCancelled()
        }
        addCardView.endEditing(true)
    }
}
