//
//  TextFieldValidationDelegate.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

/// Text Field validation delegate
///
public protocol TextFieldValidationDelegate: class {
    
    /// Called every time that isValid did change
    ///
    func isValidDidChange(_ isValid: Bool, _ textField: TextField?)
}
