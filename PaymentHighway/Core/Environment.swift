//
//  Properties.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

public enum Environment: ServerType {
    
    #if DEBUG
    public static var current: Environment = .sandbox
    #else
    public static var current: Environment = .production
    #endif
    
    case sandbox
    case production
    
    public var baseURL: String {
        switch self {
        case .sandbox: return "https://v1-hub-staging.sph-test-solinor.com/"
        case .production: return "https://v1.api.paymenthighway.io/"
        }
    }
}
