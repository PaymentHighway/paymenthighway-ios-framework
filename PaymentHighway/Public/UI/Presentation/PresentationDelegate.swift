//
//  PresentationDelegate.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 17/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import UIKit

class PresentationDelegate: NSObject, UIViewControllerTransitioningDelegate {
    let scale: PresentationScale
    
    init(scale: PresentationScale) {
        self.scale = scale
        super.init()
    }
    
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let presentationController = PresentationController(presentedViewController: presented, presenting: presenting)
        presentationController.scale = scale
        return presentationController
    }    
}
