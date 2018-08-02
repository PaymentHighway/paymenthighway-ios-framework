//
//  PresentationController.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 17/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import UIKit

class PresentationController: UIPresentationController {
    
    var presentationType: PresentationType = .fullScreen
    
    var dimmingView: UIView?
    
    override init(presentedViewController: UIViewController, presenting: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presenting)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(PresentationController.keyboardWillShow(notification:)),
                                               name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(PresentationController.keyboardWillHide(notification:)),
                                               name: .UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func createBlurView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: containerView!.bounds.width, height: containerView!.bounds.height))
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        view.addSubview(blurEffectView)
        return view
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        switch presentationType {
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
    
    public func getTranslationFrame(keyboardFrame: CGRect, presentedFrame: CGRect) -> CGRect {
        let keyboardTop = UIScreen.main.bounds.height - keyboardFrame.size.height
        let presentedViewBottom = presentedFrame.origin.y + presentedFrame.height
        let offset = presentedViewBottom - keyboardTop
        if offset > 0.0 {
            let y = presentedFrame.origin.y>=offset ? presentedFrame.origin.y-offset : 0
            let height = presentedFrame.origin.y>=offset ? presentedFrame.size.height : presentedFrame.size.height-(offset-presentedFrame.origin.y)
            return CGRect(x: presentedFrame.origin.x, y: y, width: presentedFrame.size.width, height: height)
        }
        return presentedFrame
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.keyboardEndFrame() {
            let presentedFrame = frameOfPresentedViewInContainerView
            let translatedFrame = getTranslationFrame(keyboardFrame: keyboardFrame, presentedFrame: presentedFrame)
            if translatedFrame != presentedFrame {
                UIView.animate(withDuration: notification.keyboardAnimationDuration() ?? 0.25, animations: {
                    self.presentedView?.frame = translatedFrame
                })
            }
        }
    }
    
    @objc func keyboardWillHide (notification: Notification) {
        let presentedFrame = frameOfPresentedViewInContainerView
        if self.presentedView?.frame !=  presentedFrame {
            UIView.animate(withDuration: notification.keyboardAnimationDuration() ?? 0.25, animations: {
                self.presentedView?.frame = presentedFrame
            })
        }
    }
}

extension Notification {
    
    func keyboardEndFrame () -> CGRect? {
        return (self.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    }
    
    func keyboardAnimationDuration () -> Double? {
        return (self.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
    }
}
