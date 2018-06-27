//
//  NetworkingSpec.swift
//  PaymentHighway
//
//  Created by Juha Salo on 23/05/15.
//  Copyright (c) 2015 Payment Highway Oy. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import PaymentHighway
import Alamofire

// swiftlint:disable function_body_length
class NetworkingSpec: QuickSpec {
    override func spec() {
        let merchantId = "test_merchantId"
        let accountId = "test"
        let serviceUrl = "http://54.194.196.206:8081"
        
        let networking = Networking(merchantId: merchantId, accountId: accountId)

        describe("transactionId") {
            it("we should get ID") {
                var receivedMessage = ""
                
                networking.transactionId(hostname: serviceUrl, success: {(message) in receivedMessage = message}, failure: {(error) in print("error \(error)")})
            
                expect(receivedMessage).toEventually(contain("-"), timeout: 3)
            }
            
        }

        describe("getKey") {
            it("we should get key") {
                var transactionId = ""
                var receivedKey = ""
                
                networking.transactionId(hostname: serviceUrl, success: {(message) in transactionId = message}, failure: {(error) in print("error \(error)")})
                
                expect(transactionId).toEventually(contain("-"), timeout: 3)
                
                networking.transactionKey(transactionId: transactionId,
                                          success: {(message) in receivedKey = message},
                                          failure: {(error) in print("error \(error)")})
                
                expect(receivedKey).toEventually(contain("MII"), timeout: 5)
            }
        }
        
        describe("tokenize") {
            it("we should be able to tokenize card") {
                var transactionId = ""
                var receivedKey = ""
                var receivedCode: Int = 999
                
                networking.transactionId(hostname: serviceUrl, success: {(message) in transactionId = message}, failure: {(error) in print("error \(error)")})
                
                expect(transactionId).toEventually(contain("-"), timeout: 3)
                
                networking.transactionKey(transactionId: transactionId,
                                          success: {(message) in receivedKey = message},
                                          failure: {(error) in print("error \(error)")})
                
                expect(receivedKey).toEventually(contain("MII"), timeout: 3)
                
                networking.tokenizeTransaction(transactionId: transactionId,
                                               expiryMonth: "11",
                                               expiryYear: "2023",
                                               cvc: "024",
                                               pan: "4153013999700024",
                                               certificateBase64Der: receivedKey,
                                               success: {(message) in
                                                guard let apiResult: ApiResult = Decoder.decode(fromJson: message) else { return }
                                                    receivedCode = apiResult.result.code
                                               },
                                               failure: {(error) in print("error \(error)")})
                expect(receivedCode).toEventually(equal(100), timeout: 5)
            }
        }
        
        describe("helperGetToken") {
            it("we should be able to get token") {
                var transactionId = ""
                var receivedKey = ""
                var receivedCode: Int?
                var receivedToken = ""
                
                networking.transactionId(hostname: serviceUrl, success: {(message) in transactionId = message}, failure: {(error) in print("error \(error)")})
                expect(transactionId).toEventually(contain("-"), timeout: 3)
                
                networking.transactionKey(transactionId: transactionId,
                                          success: {(message) in receivedKey = message},
                                          failure: {(error) in print("error \(error)")})
                
                expect(receivedKey).toEventually(contain("MII"), timeout: 3)
                
                networking.tokenizeTransaction(transactionId: transactionId,
                                               expiryMonth: "11",
                                               expiryYear: "2023",
                                               cvc: "024",
                                               pan: "4153013999700024",
                                               certificateBase64Der: receivedKey,
                                               success: { (message) in
                                                 guard let apiResult: ApiResult = Decoder.decode(fromJson: message) else { return }
                                                 receivedCode = apiResult.result.code
                                               },
                                               failure: {(error) in print("error \(error)")})
                
                expect(receivedCode).toEventually(equal(100), timeout: 5)

                networking.transactionToken(hostname: serviceUrl,
                                            transactionId: transactionId,
                                            success: {(message) in receivedToken = message},
                                            failure: {(error) in print("error \(error)")})
                
                expect(receivedToken).toEventually(contain("-"), timeout: 5)
            }
        }
    }
}
