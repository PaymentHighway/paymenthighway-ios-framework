//
//  BackendAdapterExampleError.swift
//  PaymentHighwayTests
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import PaymentHighway

enum BackendAdapterExampleError: Error {
    case networkError(NetworkError)
    case systemError(Error)
}

extension BackendAdapterExampleError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .systemError(let error): return "System error: \(error)"
        case .networkError(let networkError): return networkError.description
        }
    }
}
