//
//  Result.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

/// Used to represent whether a sdk operation was successful or encountered an error
/// SuccessType: Type of the value returned for a successful operation
/// ErrorType: Type of the error
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
    
    /// Returns the associated value if self represents a success,  otherwise nil
    public var value: SuccessType? {
        switch self {
        case let .success(value): return value
        case .failure: return nil
        }
    }
    
    /// Returns the accociated error if self represents a failure, otherwise nil
    public var error: ErrorType? {
        switch self {
        case .success: return nil
        case let .failure(error): return error
        }
    }
    
    /// Returns `true` if the result is a success
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    /// Returns `true` if self represents a failure, `false` otherwise.
    public var isFailure: Bool {
        return !isSuccess
    }

    /// Returns `true` if the result is a failure
    public func getOrThrow() throws -> SuccessType {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}
