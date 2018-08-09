//
//  Presenter.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 17/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import UIKit

public class Presenter<ViewControllerType: UIViewController>: NSObject, UIViewControllerTransitioningDelegate {

    public let presentationType: PresentationType
    public var presentedViewController: ViewControllerType?
    
    public init(presentationType: PresentationType) {
        self.presentationType = presentationType
        super.init()
    }
    
    deinit {
        dismissPresentedController(animated: false)
    }
    
    public func present(root: UIViewController, presentedViewController: ViewControllerType) {
        
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
