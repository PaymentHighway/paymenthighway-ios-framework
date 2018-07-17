//
//  TextFieldValidationDelegate.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 30/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

protocol TextFieldValidationDelegate: class {
    func isValidDidChange(_ isValid: Bool, _ textField: TextField?)
}
