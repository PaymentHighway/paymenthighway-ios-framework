//
//  Result.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

/// An enum which is either success with a result value or an error.
public enum Result<SuccessType, ErrorType: Error> {

    /// Indicates success with a value of the associated type
    case success(SuccessType)

    /// Indicates failure with error of the associated type
    case failure(ErrorType)
    
     /// Initialiser with a value.
    public init(value: SuccessType) {
        self = .success(value)
    }
    
    /// Initialiser with a error.
    public init(error: ErrorType) {
        self = .failure(error)
    }
}
