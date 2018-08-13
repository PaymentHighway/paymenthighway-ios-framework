//
//  RequestAdapter.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation
import Alamofire

class NetworkingRequestAdapter: RequestAdapter {
    let merchantId: String
    let accountId: String
    
    init(merchantId: String, accountId: String) {
        self.merchantId = merchantId
        self.accountId = accountId
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var request = urlRequest
        
        request.addValue(merchantId, forHTTPHeaderField: "SPH-Merchant")
        request.addValue(accountId, forHTTPHeaderField: "SPH-Account")
        request.addValue(NSUUID().uuidString.lowercased(), forHTTPHeaderField: "SPH-Request-ID")
        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let utcTimeZoneStr = formatter.string(from: date)
        
        request.addValue(utcTimeZoneStr, forHTTPHeaderField: "SPH-Timestamp")

        return request
    }
}
