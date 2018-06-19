//
//  Networking.swift
//  PaymentHighway
//
//  Created by Nico Hämäläinen on 06/03/2017.
//  Copyright © 2017 Payment Highway Oy. All rights reserved.
//

import Foundation
import Alamofire

internal class Networking {
    let sessionManager: Alamofire.SessionManager
    let requestAdapter: NetworkingRequestAdapter
    
    init(merchantId: String, accountId: String) {
        // Create request adapter
        requestAdapter = NetworkingRequestAdapter(
            merchantId: merchantId,
            accountId: accountId
        )
        
        // Create session manager
        sessionManager = SessionManager()
        sessionManager.adapter = requestAdapter
    }
    
    // (hostname)/mobile-key
    func transactionId(hostname: String, success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        sessionManager.request(NetworkingRouter.transactionId(hostname))
            .responseJSON { response in
                switch response.result {
                case .success(let json):
                    if let json = json as? [String: Any], let id = json["id"] as? String {
                        success(id)
                    } else {
                        failure(NSError(domain: "io.paymenthighway.ios", code: 100, userInfo: nil))
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    failure(error)
                }
            }
    }
    
    // (hostname)/tokenization/(transactionId)
    func transactionToken(hostname: String, transactionId: String, success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        sessionManager.request(NetworkingRouter.transactionToken(hostname, transactionId))
            .responseJSON { response in
                switch response.result {
                case .success(let json):
                    if let json = json as? [String: Any], let token = json["token"] as? String {
                        success(token)
                    } else {
                        failure(NSError(domain: "io.paymenthighway.ios", code: 100, userInfo: nil))
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    failure(error)
                }
            }
    }
    
    // (sph)/mobile/(transactionId)/key
    func transactionKey(transactionId: String, success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        sessionManager.request(NetworkingRouter.transactionKey(transactionId))
            .responseJSON { response in
                switch response.result {
                case .success(let json):
                    if let json = json as? [String: Any], let key = json["key"] as? String {
                        success(key)
                    } else {
                        failure(NSError(domain: "io.paymenthighway.ios", code: 100, userInfo: nil))
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    failure(error)
                }
            }
    }
    
    // (sph)/mobile/(transactionId)/tokenize
    func tokenizeTransaction(transactionId: String,
                             expiryMonth: String,
                             expiryYear: String,
                             cvc: String,
                             pan: String,
                             certificateBase64Der: String,
                             success: @escaping (String) -> Void,
                             failure: @escaping (Error) -> Void) {
        // Encrypt card data
        let jsonCardData = ["expiry_month": expiryMonth, "expiry_year": expiryYear, "cvc" : cvc, "pan" : pan]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonCardData, options: []),
              let data = String(data: jsonData, encoding: .utf8),
              let encryptedCardData = encryptWithRsaAes(data, certificateBase64Der: certificateBase64Der) else {
            failure(NSError(domain: "io.paymenthighway.ios", code: 5, userInfo: ["errorReason" : "Could not encrypt data during network.tokenize."]))
            return
        }
        
        // Create JSON payload
        let parameters: [String : Any] = [
            "encrypted" : encryptedCardData.encryptedBase64Message,
            "key" : [
                "key" : encryptedCardData.encryptedBase64Key,
                "iv" : encryptedCardData.iv
            ]
        ]
        
        sessionManager.request(NetworkingRouter.tokenizeTransaction(transactionId, parameters))
            .responseString { response in
                switch response.result {
                case .success(let value):
                    print(value)
                    success(value)
                case .failure(let error):
                    print(error.localizedDescription)
                    failure(error)
                }
            }
    }
}
