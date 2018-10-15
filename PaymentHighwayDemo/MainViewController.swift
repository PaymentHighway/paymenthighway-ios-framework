//
//  MainViewController.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import UIKit
import PaymentHighway

protocol TableRowItem {
    var title: String { get }
    var details: String? { get }
    static var count: Int { get }
}

extension TableRowItem {
    var details: String? {
        return nil
    }
}

protocol TableSectionItem: TableRowItem {
    var rows: [TableRowItem] { get }
}

func simpleAlert(title: String, message: String, seconds: Int = 0, completion: @escaping () -> Void = {}) -> UIAlertController {
    
    let alertController = UIAlertController(title: title, message: nil, preferredStyle:.alert)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .left
    let messageText = NSMutableAttributedString(string: message)
    let range = NSRange(location: 0, length: message.endIndex.encodedOffset)
    messageText.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
    messageText.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .body), range: range)
    messageText.addAttribute(.foregroundColor, value: UIColor.black, range: range)
    alertController.setValue(messageText, forKey: "attributedMessage")
    
    if seconds == 0 {
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { (_) in completion()})
    } else {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(seconds)) {
            alertController.dismiss(animated: true, completion: completion)
        }
    }
    return alertController
}

class MainViewController: UITableViewController, AddCardDelegate, PayWithCardDelegate, SettingsDelegate {
    
    var presenterAddCard: Presenter<AddCardViewController>?
    var presenterPayWithCard: Presenter<PayWithCardViewController>?
    var paymentContext: PaymentContext<BackendAdapterExample>!
    
    let merchantId = MerchantId(id: "test_merchantId")
    let accountId = AccountId(id: "test")

    let rowHeight: CGFloat = 50
    
    var presentationType: PresentationType = .fullView
    
    var themes: [ThemeItem: Theme] = [.default: DefaultTheme.instance, .dark: DarkTheme()]
    var themeItem: ThemeItem = .default
    
    var theme: Theme {
        return themes[themeItem]!
    }
    
    enum MainRowItem: Int, TableRowItem {
        case addCardView
        case payWithCard
        case settings

        var title: String {
            switch self {
            case .addCardView: return "Add Card"
            case .payWithCard: return "Pay with Card"
            case .settings: return "Settings"
            }
        }
        
        static var count: Int {
            return 3
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let paymentConfig = PaymentConfig(merchantId: merchantId, accountId: accountId, environment: Environment.sandbox)
        paymentContext = PaymentContext(config: paymentConfig, backendAdapter: BackendAdapterExample())
        title = "Payment Highway Demo"
        tableView.tableFooterView = UIView()
        tableView.rowHeight = rowHeight
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: UITableViewDelegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MainRowItem.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        if let rowItem = MainRowItem(rawValue: indexPath.row) {
            cell.selectionStyle = .none
            cell.textLabel?.text = rowItem.title
            cell.accessoryType = .disclosureIndicator
            cell.detailTextLabel?.text = rowItem.details
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cellItem = MainRowItem(rawValue: indexPath.row) else { return }
        DispatchQueue.main.async(execute: {
            switch cellItem {
            case .addCardView: self.presentAddCardViewController(presentationType: self.presentationType)
            case .payWithCard:  self.presentPayWithCardViewController(presentationType: self.presentationType)
            case .settings: self.presentSettingsViewController()
            }
        })
    }
    
    // MARK: AddCardDelegate
    
    func addCardCancelled() {
        self.presenterAddCard?.dismissPresentedController(animated: true) { () in
            self.presenterAddCard = nil
        }
    }
    
    func addCard(_ card: CardData) {
        paymentContext.addCard(card: card) { (result) in
            switch result {
            case .success(let transactionToken):
                self.presenterAddCard?.dismissPresentedController(animated: true) { () in
                    self.presenterAddCard = nil
                    let message = """
                    
                        Ready for payment:
                    
                        token: \(transactionToken.token.suffix(8))...
                        brand: \(transactionToken.card.cardType)
                        last digits: \(transactionToken.card.partialPan)
                        expiry date:\(transactionToken.card.expireMonth)/\(transactionToken.card.expireYear)
                    """
                    let alert = simpleAlert(title: "Add Card completed!", message: message)
                    self.present(alert, animated: true)
                }
            case .failure(let error):
                self.presenterAddCard?.presentedViewController?.showToast(message: "\(error)")
            }
        }
    }

    // MARK: PayWithCardDelegate

    func paymentCancelled() {
        self.presenterPayWithCard?.dismissPresentedController(animated: true) { () in
            self.presenterPayWithCard = nil
        }
    }
    
    func executePayment(purchase: Purchase, card: CardData) {
        //TODO
        print("EXECUTE PAYMENT!!!!")
    }

    // MARK: SettingsDelegate
    
    func presentationTypeDidChange(presentationType: PresentationType) {
        self.presentationType = presentationType
    }
    
    func themeDidChange(themeItem: ThemeItem) {
        self.themeItem = themeItem
        tableView.reloadData()
    }

    // MARK: private
    
    private func presentAddCardViewController(presentationType: PresentationType) {
        guard presenterAddCard == nil else { return }
        
        let addCardViewController = AddCardViewController(theme: theme)
        addCardViewController.addCardDelegate = self
        presenterAddCard = Presenter(presentationType: presentationType)
        presenterAddCard!.present(presentingViewController: self, presentedViewController: addCardViewController)
    }
    
    private func presentPayWithCardViewController(presentationType: PresentationType) {
        guard presenterPayWithCard == nil else { return }
        
        let description = "This is the purchase description"
        
        let purchase = Purchase(purchaseId: PurchaseId(id: "purchaseID"), currency: "EUR", amount: 199.99, description: description)
        let payWithCardViewController = PayWithCardViewController(purchase: purchase, theme: theme)
        payWithCardViewController.payWithCardDelegate = self
        presenterPayWithCard = Presenter(presentationType: presentationType)
        presenterPayWithCard!.present(presentingViewController: self, presentedViewController: payWithCardViewController)
    }
    
    private func presentSettingsViewController() {
        let settingsVC = SettingsViewController(presenterType: presentationType, themeItem: themeItem, delegate: self)
        let navigationController = UINavigationController(rootViewController: settingsVC)
        present(navigationController, animated: true)
    }
    
}
