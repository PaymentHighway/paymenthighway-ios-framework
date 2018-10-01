//
//  Properties.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

/// Payment Highway environment interface
public protocol EnvironmentInterface: ServerBaseURL {}

public enum Environment: EnvironmentInterface {
    
    /// Payment Highway sandbox environment for testing
    case sandbox

    /// Payment Highway production environment
    case production

    public var baseURL: URL {
        switch self {
        case .sandbox: return  URL(string: "https://v1-hub-staging.sph-test-solinor.com/")!
        case .production: return URL(string: "https://v1.api.paymenthighway.io/")!
        }
    }
}
