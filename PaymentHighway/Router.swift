//
//  Router.swift
//  PaymentHighway
//
//  Created by Nico Hämäläinen on 06/03/2017.
//  Copyright © 2017 Solinor Oy. All rights reserved.
//

import Foundation
import Alamofire

internal enum NetworkingRouter: URLRequestConvertible {
    static let serviceBaseURL = "https://v1-hub-staging.sph-test-solinor.com"

    case transactionId(String)
    case transactionToken(String, String)
    case transactionKey(String)
    case tokenizeTransaction(String, [String: Any])
    
    var method: HTTPMethod {
        switch self {
        case .transactionId, .transactionKey:
            return .get
        case .transactionToken, .tokenizeTransaction:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .transactionId(let hostname):
            return "\(hostname)/mobile-key"
        case .transactionToken(let hostname, let transactionId):
            return "\(hostname)/tokenization/\(transactionId)"
        case .transactionKey(let transactionId):
            return "/mobile/\(transactionId)/key"
        case .tokenizeTransaction(let transactionId, _):
            return "/mobile/\(transactionId)/tokenize"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url: URL
        var httpBody: Data? = nil
        
        switch self {
        // Don't forward these two calls to the payment highway service
        case .transactionId, .transactionToken:
            url = URL(string: path)!
            break
        // But forward everything else there
        default:
            url = URL(string: NetworkingRouter.serviceBaseURL.appending(path))!
            break
        }
        
        switch self {
        case .tokenizeTransaction(_, let parameters):
            httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
            break
        default:
            break
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = httpBody
        
        return urlRequest
    }
}
