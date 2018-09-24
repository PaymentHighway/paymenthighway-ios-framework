//
//  PaymentHighwayEndpoint.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Alamofire

enum PaymentHighwayEndpoint {
    
    // (ph)/mobile/(transactionId)/key
    case encryptionKey(merchantId: MerchantId, accountId: AccountId, transactionId: TransactionId)
    
    //(ph)/mobile/(transactionId)/tokenize
    case tokenizeTransaction(merchantId: MerchantId, accountId: AccountId, transactionId: TransactionId, parameters: [String: Any])
}

extension PaymentHighwayEndpoint : Endpoint {
 
    var baseURL: URL {
        let url = URL(string: Environment.current.baseURL)
        precondition(url != nil)
        return url!
    }
    
    var path: String? {
        switch self {
        case .encryptionKey(_, _, let transactionId):
            return "/mobile/\(transactionId.id)/key"
        case .tokenizeTransaction(_, _, let transactionId, _):
            return "/mobile/\(transactionId.id)/tokenize"
        }
    }
    
    var parameters: Parameters? {
        if case .tokenizeTransaction(_, _, _, let parameters) = self {
            return parameters
        }
        return nil
    }

    var requestAdapter: RequestAdapter? {
        switch self {
        case .encryptionKey(let merchantId, let accountId, _):
            return NetworkingRequestAdapter(merchantId: merchantId.id, accountId: accountId.id)
        case .tokenizeTransaction(let merchantId, let accountId, _, _):
            return NetworkingRequestAdapter(merchantId: merchantId.id, accountId: accountId.id)
        }
    }
}
