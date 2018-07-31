//
//  PresentationController.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 17/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import UIKit

class PresentationController: UIPresentationController {
    
    var scale: PresentationScale = .fullScreen
    
    var dimmingView: UIView?
    
    private func createBlurView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: containerView!.bounds.width, height: containerView!.bounds.height))
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        view.addSubview(blurEffectView)
        return view
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        switch scale {
        case .custom(let height):
            return CGRect(x: 0, y: containerView!.bounds.height - height, width: containerView!.bounds.width, height: height)
        case .halfScreen:
            return CGRect(x: 0, y: containerView!.bounds.height / 2, width: containerView!.bounds.width, height: containerView!.bounds.height / 2)
        case .fullScreen:
            return  containerView!.bounds
        }
    }
    
    override func presentationTransitionWillBegin() {
        dimmingView = createBlurView()
        if let containerView = self.containerView, let coordinator = presentingViewController.transitionCoordinator, let dimmingView = dimmingView {
            
            dimmingView.alpha = 0
            containerView.addSubview(dimmingView)
            dimmingView.addSubview(presentedViewController.view)
            
            coordinator.animate(alongsideTransition: { (_) -> Void in
                dimmingView.alpha = 0.8
                //self.presentingViewController.view.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            })
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentingViewController.transitionCoordinator {
            
            coordinator.animate(alongsideTransition: { (_) -> Void in
                self.dimmingView?.alpha = 0
            })
            
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView?.removeFromSuperview()
            dimmingView = nil
        }
    }
}
