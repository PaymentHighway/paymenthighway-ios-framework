//
//  MainViewController.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 08/08/2018.
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

func simpleAlert(message: String, seconds: Int, completion: @escaping () -> Void = {}) -> UIAlertController {
    
    let alertController = UIAlertController(title: message, message :nil, preferredStyle:.alert)
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(seconds)) {
        alertController.dismiss(animated: true, completion: completion)
    }
    return alertController
}

class MainViewController: UITableViewController, AddCardDelegate, SettingsDelegate {
    
    var presenter: Presenter<AddCardViewController>?
    var paymentContext: PaymentContext<BackendAdapterExample>!
    
    let merchantId = MerchantId(id: "test_merchantId")
    let accountId = AccountId(id: "test")

    let rowHeight: CGFloat = 50
    
    var presentationType: PresentationType = .halfScreen
    
    var themes: [ThemeItem: Theme] = [.default: DefaultTheme.instance, .dark: DarkTheme()]
    var themeItem: ThemeItem = .default
    
    var theme: Theme {
        return themes[themeItem]!
    }
    
    enum MainRowItem: Int, TableRowItem {
        case addCardView
        case settings

        var title: String {
            switch self {
            case .addCardView: return "Add Card"
            case .settings: return "Settings"
            }
        }
        
        static var count: Int {
            return 2
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let paymentConfig = PaymentConfig(merchantId: merchantId, accountId: accountId)
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
            case .settings: self.presentSettingsViewController()
            }
        })
    }
    
    // MARK: AddCardDelegate
    
    func cancel() {
        self.presenter?.dismissPresentedController(animated: true) { () in
            self.presenter = nil
        }
    }
    
    func addCard(_ card: CardData) {
        paymentContext.addCard(card: card) { (result) in
            switch result {
            case .success(let transactionToken):
                self.presenter?.dismissPresentedController(animated: true) { () in
                    self.presenter = nil
                    let alert = simpleAlert(message: "Received transaction token: \(transactionToken.token)", seconds: 2)
                    self.present(alert, animated: true)
                }
            case .failure(let error):
                self.presenter?.presentedViewController?.showError(message: "\(error)")
            }
        }
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
        guard presenter == nil else { return }
        
        let addCardViewController = AddCardViewController(theme: theme)
        addCardViewController.addCardDelegate = self
        presenter = Presenter(presentationType: presentationType)
        presenter!.present(presentingViewController: self, presentedViewController: addCardViewController)
    }
    
    private func presentSettingsViewController() {
        let settingsVC = SettingsViewController(presenterType: presentationType, themeItem: themeItem, delegate: self)
        let navigationController = UINavigationController(rootViewController: settingsVC)
        present(navigationController, animated: true)
    }
    
}
