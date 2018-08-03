//
//  TextFieldType.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 01/08/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

public enum TextFieldType {
    case cardNumber
    case expirationDate
    case securityCode
}

extension TextFieldType {
    func iconId(cardBrand: CardBrand?) -> String {
        switch self {
        case .cardNumber: return "cardicon"
        case .expirationDate: return "calendaricon"
        case .securityCode: return "lockicon"
        }
    }
}
