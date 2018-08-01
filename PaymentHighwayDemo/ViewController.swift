//
//  ViewController.swift
//  PaymentHighwayDemo
//
//  Created by Nico Hämäläinen on 01/04/15.
//  Copyright (c) 2015 Payment Highway Oy. All rights reserved.
//

import UIKit
import PaymentHighway

class ViewController: UIViewController, AddCardDelegate {
    private let viewHeight: CGFloat = 300
    
    var presenter: Presenter?
    var paymentContext: PaymentContext<BackendAdapterTest>!

    let merchantId = MerchantId(id: "test_merchantId")
    let accountId = AccountId(id: "test")
    
	override func viewDidLoad() {
		super.viewDidLoad()
        let paymentConfig = PaymentConfig(merchantId: merchantId, accountId: accountId)
        paymentContext = PaymentContext(config: paymentConfig, backendAdapter: BackendAdapterTest())
	}
	
    private func executeAddCard(card: CardData) {
        paymentContext.addCard(card: card) { (result) in
            switch result {
            case .success(let transactionToken):
                self.logForUser.text = "AddCard success, transaction token:\(transactionToken)\n\(self.logForUser.text ?? "")"
            case .failure(let error):
                self.logForUser.text = "AddCard error:\(error)\n\(self.logForUser.text ?? "")"
            }
        }
    }
    
    @IBOutlet weak var logForUser: UITextView!
  
    @IBAction func addCard(_ sender: UIButton) {
        guard presenter == nil else { return }
        let vcAddCard = AddCardViewController(theme: DefaultTheme.instance)
        
        vcAddCard.addCardDelegate = self
        presenter = Presenter.addCardPresenter(theme: DefaultTheme.instance)
        presenter!.present(root: self, presentedViewController: vcAddCard)
    }
    
    private func dismiss() {
        self.presenter = nil
    }
    
    func cancel() {
        self.logForUser.text = "AddCard cancel\n\(self.logForUser.text ?? "")"
        self.presenter = nil
    }
    
    func addCard(_ card: CardData) {
        self.executeAddCard(card: card)
        self.presenter = nil
    }
}
