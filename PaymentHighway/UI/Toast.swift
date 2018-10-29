//
//  Toast.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

private let toastLabelPadding: CGFloat = 15
private let toastBottomPadding: CGFloat = 10

/// Toast position
public enum ToastPosition {
    case top
    case bottom
}

/// Toast Helper to show toast message on the top or in the bottom of the view
class Toast {
    
    class func show(view: UIView, theme: Theme, message: String, completion: (() -> Void)? = nil) {
        
        let container = UIView(frame: CGRect())
        container.backgroundColor = theme.errorForegroundColor
        container.alpha = 0.0
        container.layer.cornerRadius = theme.toastRadius
        container.clipsToBounds  =  true
       
        let label = UILabel(frame: CGRect())
        // Invert the error color
        label.backgroundColor = theme.errorForegroundColor
        label.textColor = theme.secondaryBackgroundColor
        label.textAlignment = .center
        label.font = theme.font
        label.text = message
        label.clipsToBounds  =  true
        label.numberOfLines = 0

        container.addSubview(label)
        
        view.addSubview(container)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        
        labelConstraints(label: label, container: container)
        containerConstraints(theme: theme, container: container, view: view)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            container.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                container.alpha = 0.0
            }, completion: {_ in
                container.removeFromSuperview()
                completion?()
            })
        })
    }
   
    private class func labelConstraints(label: UILabel, container: UIView) {
        let leadingConstraint = NSLayoutConstraint(item: label,
                                                   attribute: .leading,
                                                   relatedBy: .equal,
                                                   toItem: container,
                                                   attribute: .leading,
                                                   multiplier: 1,
                                                   constant: toastLabelPadding)
        let trailingConstraint = NSLayoutConstraint(item: label,
                                                    attribute: .trailing,
                                                    relatedBy: .equal,
                                                    toItem: container,
                                                    attribute: .trailing,
                                                    multiplier: 1,
                                                    constant: -toastLabelPadding)
        let bottomConstraint = NSLayoutConstraint(item: label,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: container,
                                                  attribute: .bottom,
                                                  multiplier: 1,
                                                  constant: -toastLabelPadding)
        let topConstraint = NSLayoutConstraint(item: label,
                                               attribute: .top,
                                               relatedBy: .equal,
                                               toItem: container,
                                               attribute: .top,
                                               multiplier: 1,
                                               constant: toastLabelPadding)
        container.addConstraints([leadingConstraint, trailingConstraint, bottomConstraint, topConstraint])
    }
    
    private class func containerConstraints(theme: Theme, container: UIView, view: UIView) {
        let leadingConstraint = NSLayoutConstraint(item: container,
                                                   attribute: .leading,
                                                   relatedBy: .equal,
                                                   toItem: view,
                                                   attribute: .leading,
                                                   multiplier: 1,
                                                   constant: theme.toastPadding)
        let trailingConstraint = NSLayoutConstraint(item: container,
                                                    attribute: .trailing,
                                                    relatedBy: .equal,
                                                    toItem: view,
                                                    attribute: .trailing,
                                                    multiplier: 1,
                                                    constant: -theme.toastPadding)
        var topBottomConstraint: NSLayoutConstraint
        if theme.toastPosition == .top {
            topBottomConstraint = NSLayoutConstraint(item: container,
                                                   attribute: .top,
                                                   relatedBy: .equal,
                                                   toItem: view,
                                                   attribute: .top,
                                                   multiplier: 1,
                                                   constant: 0)
        } else {
            var bottomPadding: CGFloat = 0
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.keyWindow
                bottomPadding = window?.safeAreaInsets.bottom ?? 0
            }
            topBottomConstraint = NSLayoutConstraint(item: container,
                                                     attribute: .bottom,
                                                     relatedBy: .equal,
                                                     toItem: view,
                                                     attribute: .bottom,
                                                     multiplier: 1,
                                                     constant: -bottomPadding)
        }
        view.addConstraints([leadingConstraint, trailingConstraint, topBottomConstraint])
    }
}
