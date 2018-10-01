//
//  PaymentHighwayEndpoint.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Alamofire

enum PaymentHighwayEndpoint {
    
    // (ph)/mobile/(transactionId)/key
    case encryptionKey(config: PaymentConfig, transactionId: TransactionId)
    
    //(ph)/mobile/(transactionId)/tokenize
    case tokenizeTransaction(config: PaymentConfig, transactionId: TransactionId, parameters: [String: Any])
}

extension PaymentHighwayEndpoint : Endpoint {
 
    var baseURL: URL {
        switch self {
        case .encryptionKey(let config, _):
            return config.environment.baseURL
        case .tokenizeTransaction(let config, _, _):
            return config.environment.baseURL
        }
    }
    
    var path: String? {
        switch self {
        case .encryptionKey(_, let transactionId):
            return "/mobile/\(transactionId.id)/key"
        case .tokenizeTransaction(_, let transactionId, _):
            return "/mobile/\(transactionId.id)/tokenize"
        }
    }
    
    var parameters: Parameters? {
        if case .tokenizeTransaction(_, _, let parameters) = self {
            return parameters
        }
        return nil
    }

    var requestAdapter: RequestAdapter? {
        switch self {
        case .encryptionKey(let config, _):
            return NetworkingRequestAdapter(merchantId: config.merchantId.id, accountId: config.accountId.id)
        case .tokenizeTransaction(let config, _, _):
            return NetworkingRequestAdapter(merchantId: config.merchantId.id, accountId: config.accountId.id)
        }
    }
}
