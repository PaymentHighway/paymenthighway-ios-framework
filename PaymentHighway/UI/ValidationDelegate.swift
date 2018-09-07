//
//  ValidationDelegate.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

/// Validation delegate
///
public protocol ValidationDelegate: class {
    
    /// Called every time the related item validation did change
    ///
    func isValidDidChange(_ isValid: Bool, _ textField: TextField?)
}
