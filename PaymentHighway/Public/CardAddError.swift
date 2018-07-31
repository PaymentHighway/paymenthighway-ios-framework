//
//  CardAddError.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 28/06/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

public enum CardAddError: Error {
    case cancel
    case networkError(Error)
}
