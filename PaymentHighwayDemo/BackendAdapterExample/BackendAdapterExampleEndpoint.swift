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
        return URL(string: "https://ssocw2l28c.execute-api.eu-west-1.amazonaws.com/staging")!
    }
    
    var path: String? {
        switch self {
        case .transactionId:
            return "/paymenthighway/transaction"
        case .transactionToken(let transactionId):
            return "/paymenthighway/tokenization/\(transactionId.id)"
        }
    }
}
