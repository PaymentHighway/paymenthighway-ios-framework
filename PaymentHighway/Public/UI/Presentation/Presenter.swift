//
//  Presenter.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 17/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import UIKit

public class Presenter: NSObject, UIViewControllerTransitioningDelegate {

    let presentationType: PresentationType
    var presentedViewController: UIViewController?
    
    public init(presentationType: PresentationType) {
        self.presentationType = presentationType
        super.init()
    }
    
    deinit {
        dismissPresentedController(animated: false)
    }
    
    public static func addCardPresenter(theme: Theme) -> Presenter {
        return Presenter(presentationType: theme.addCardPresentationType)
    }
    
    public func present(root: UIViewController, presentedViewController: UIViewController) {
        
        let navigation = UINavigationController(rootViewController: presentedViewController)
        
        navigation.modalPresentationStyle = .custom
        navigation.transitioningDelegate = self
        dismissPresentedController(animated: false)
        self.presentedViewController = presentedViewController
        root.present(navigation, animated: true)
    }
    
    public func dismissPresentedController(animated: Bool, completion: (() -> Void)? = nil) {
        presentedViewController?.dismiss(animated: animated, completion: completion)
    }
    
    public func presentationController(forPresented presented: UIViewController,
                                       presenting: UIViewController?,
                                       source: UIViewController) -> UIPresentationController? {
        let presentationController = PresentationController(presentedViewController: presented, presenting: presenting)
        presentationController.presentationType = presentationType
        return presentationController
    }
}