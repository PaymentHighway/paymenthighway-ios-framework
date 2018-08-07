//
//  BackendAdapterExampleEndpoint.swift
//  PaymentHighwayTests
//
//  Created by Stefano Pironato on 06/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import PaymentHighway
import Alamofire

enum BackendAdapterExampleEndpoint {
    case transactionId
    case transactionToken(transactionId: TransactionId)
}

extension BackendAdapterExampleEndpoint : Endpoint {
    
    var baseURL: URL {
        return URL(string: "http://54.194.196.206:8081")!
    }
    
    var path: String? {
        switch self {
        case .transactionId:
            return "/mobile-key"
        case .transactionToken(let transactionId):
            return "/tokenization/\(transactionId.id)"
        }
    }
}
