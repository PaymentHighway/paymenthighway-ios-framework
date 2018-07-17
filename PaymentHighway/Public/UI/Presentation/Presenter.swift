//
//  Presenter.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 17/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import UIKit

// swiftlint:disable  weak_delegate
public class Presenter {

    private var presentationHandler: PresentationHandler
    private let viewHeight: CGFloat = 450
    
    public init() {
        presentationHandler = PresentationHandler()
    }
    
    public func showAddCard(root: UIViewController, title: String? = nil, delegate: AddCardDelegate) {
        
        guard presentationHandler.presentationDelegate == nil else { return }
        
        let vcAddCard = AddCardViewController()

        let navigation = UINavigationController(rootViewController: vcAddCard)
        
        presentationHandler.createDelegate(scale: .custom(viewHeight), delegate: delegate)
        vcAddCard.addCardDelegate = presentationHandler
        vcAddCard.title = title

        navigation.modalPresentationStyle = .custom
        navigation.transitioningDelegate = presentationHandler.presentationDelegate
        root.present(navigation, animated: true)
    }
}

private class PresentationHandler: AddCardDelegate {
    
    var presentationDelegate: PresentationDelegate?
    
    weak var delegate: AddCardDelegate?
    
    func clean() {
        presentationDelegate = nil
        delegate = nil
    }
    
    func cancel() {
        delegate?.cancel()
        clean()
    }
    
    func addCard(_ card: CardData) {
        delegate?.addCard(card)
        clean()
    }
    
    func createDelegate(scale: PresentationScale, delegate: AddCardDelegate) {
        self.delegate = delegate
        self.presentationDelegate = PresentationDelegate(scale: scale)
    }
}
