//
//  TextFieldIcon.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 16/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

public enum TextFieldIcon: String {
    case cardNumber = "cardicon"
    case expirationDate = "calendaricon"
    case securityCode = "lockicon"
    
    func getImageView(height: CGFloat) -> UIImageView {
        let iconImageView = UIImageView(frame: CGRect.zero)
        iconImageView.image = UIImage(named: self.rawValue, in: Bundle(identifier: "io.paymenthighway.PaymentHighway"), compatibleWith: nil)
        iconImageView.frame = CGRect(x: 0, y: 0, width: height, height: height)
        iconImageView.contentMode = UIViewContentMode.scaleAspectFit
        return iconImageView
    }
}
