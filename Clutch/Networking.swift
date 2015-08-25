//
//  Networking.swift
//  Clutch
//
//  Created by Juha Salo on 22/05/15.
//  Copyright (c) 2015 Solinor Oy. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public class Networking {
    
    private var manager: Manager!
    
    public let resultStringTokenisationSuccess = "Tokenisation OK"
    
    private var mobileApiAddress: String?
    
    private let merchantId: String
    
    private let account: String
    
    public enum errorCode: Int {
        case ServerResponseInvalid, Unknown
    }
    
    public init(merchant: String, accountId: String, host: String) {
        mobileApiAddress = host
        
        merchantId = merchant
        
        account = accountId
        
        manager = getManagerWithDefaults(merchant, account: accountId)
    }
    
    private func getManagerWithDefaults(merchant: String, account: String) -> Manager {
        
        var defaultHeaders: [NSObject:AnyObject] = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
        defaultHeaders["SPH-Merchant"] = merchant 
        defaultHeaders["SPH-Account"] = account
        defaultHeaders["Content-Type"] = "application/json; charset=utf-8"
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = defaultHeaders
        
        return Alamofire.Manager(configuration: configuration)
    }
    
    private func getSphHeaders(requestId: String) -> [String: String]
    {
        let date = NSDate()
        
        var formatter = NSDateFormatter();
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'";
        formatter.timeZone = NSTimeZone(abbreviation: "UTC");
        let utcTimeZoneStr = formatter.stringFromDate(date);
        
        return [
            "SPH-Timestamp" : utcTimeZoneStr,
            "SPH-Request-ID" : requestId
        ]
    }
    
    public func helperGetTransactionId(host: String, success: (String) -> (), failure: (NSError) -> ()) -> () {
        var reqId = getRequestId() // requestId not validated for this call

            manager.request(.GET, "\(host)/mobile-key").responseJSON{(request, response, data, error) in
            if let errorMessage = error {
                println("Networking.helperGetTransactionId most likely received malformed data from server.")
                failure(errorMessage)
            } else if let json: AnyObject = data {
                let transactionId = JSON(json)["id"].stringValue
                
                if count(transactionId) > 0
                {
                    success(transactionId)
                } else {
                    failure(NSError(domain: ClutchDomains.Default, code: errorCode.ServerResponseInvalid.rawValue, userInfo: ["errorReason" : "Server did not return a valid transaction id."]))
                }

            } else {
                failure(NSError(domain: ClutchDomains.Default, code: errorCode.Unknown.rawValue, userInfo: ["errorReason" : "Unknown error during helperGetTransactionId"]))
            }
        }
    }
    
    public func getKey(transactionId: String, success: (String) -> (), failure: (NSError) -> ()) -> () {
        var reqId = getRequestId()
        manager.request(.GET, "\(self.mobileApiAddress!)/mobile/\(transactionId)/key", headers: getSphHeaders(reqId)).responseJSON{(request, response, data, error) in
            if let errorMessage = error {
                println("Networking.getKey most likely received malformed data from server.")
                failure(errorMessage)
            } else if let json: AnyObject = data {
                let key = JSON(json)["key"].stringValue
                if count(key) > 0 && self.doesContainValidRequestId(response, requestId: reqId)
                {
                    success(key)
                } else {
                    failure(NSError(domain: ClutchDomains.Default, code: errorCode.ServerResponseInvalid.rawValue, userInfo: ["errorReason" : "Server did not return a key or received requestId was invalid."]))
                }
            } else {
                failure(NSError(domain: ClutchDomains.Default, code: errorCode.Unknown.rawValue, userInfo: ["errorReason" : "Unknown error during getKey"]))
            }
        }
    }
    
    public func tokenize(transactionId: String, expiryMonth: String, expiryYear: String, cvc: String, pan: String, certificateBase64Der: String, success: (String) -> (), failure: (NSError) -> ()) -> () {
    
        let jsonCardData = JSON(["expiry_month": expiryMonth, "expiry_year": expiryYear, "cvc" : cvc, "pan" : pan])
        if let encrypted = encryptWithRsaAes(jsonCardData.description, certificateBase64Der)
        {
            let payloadJson = ["encrypted" : encrypted.encryptedBase64Message, "key" : ["key" : encrypted.encryptedBase64Key, "iv" : encrypted.iv]]
            
            let custom: (URLRequestConvertible, [String: AnyObject]?) -> (NSMutableURLRequest, NSError?) = {
                (URLRequest, parameters) in
                let mutableURLRequest = URLRequest.URLRequest.mutableCopy() as! NSMutableURLRequest
                mutableURLRequest.HTTPBody = ("\(JSON(parameters!))").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                return (mutableURLRequest, nil)
            }
            
            var reqId = getRequestId()
            manager.request(.POST, "\(self.mobileApiAddress!)/mobile/\(transactionId)/tokenize", parameters: payloadJson as? [String : AnyObject], encoding: .Custom(custom), headers: getSphHeaders(reqId)).responseJSON{(request, response, data, error) in

                if let errorMessage = error {
                    println("Networking.tokenize most likely received malformed data from server.")
                    failure(errorMessage)
                } else if let json: AnyObject = data {
                    let code = JSON(json)["result"]["code"].int
                    let message = JSON(json)["result"]["message"].stringValue
                    
                    if code == 100 && message == "OK" && self.doesContainValidRequestId(response, requestId: reqId)
                    {
                        success(self.resultStringTokenisationSuccess)
                    }
                    else {
                        failure(NSError(domain: ClutchDomains.Default, code: errorCode.ServerResponseInvalid.rawValue, userInfo: ["errorReason" : "tokenize did not result in success or received requestId was invalid.. Result message: \(json)"]))
                    }
                } else {
                    failure(NSError(domain: ClutchDomains.Default, code: errorCode.Unknown.rawValue, userInfo: ["errorReason" : "Unknown error during tokenize"]))
                }
            }
        }
        else {
            failure(NSError(domain: ClutchDomains.Default, code: 5, userInfo: ["errorReason" : "Could not encrypt data during network.tokenize."]))
        }
    }
    
    public func helperGetToken(host: String, transactionId: String, success: (String) -> (), failure: (NSError) -> ()) -> () {
        var reqId = getRequestId() // request id not validated for this call
        manager.request(.GET, "\(host)/tokenization/\(transactionId)", headers: getSphHeaders(reqId)).responseJSON{(request, response, data, error) in
            if let errorMessage = error {
                println("Networking.helperGetToken most likely received malformed data from server.")
                failure(errorMessage)
            } else if let dataMessage: AnyObject = data {
                if count(JSON(dataMessage)["token"].stringValue) > 0
                {
                    success(JSON(dataMessage).description)
                } else {
                    failure(NSError(domain: ClutchDomains.Default, code: errorCode.ServerResponseInvalid.rawValue, userInfo: ["errorReason" : "helperGetToken did not receive correct token from server: \(JSON(dataMessage).description)"]))
                }
            } else {
                failure(NSError(domain: ClutchDomains.Default, code: errorCode.Unknown.rawValue, userInfo: ["errorReason" : "Unknown error during helperGetToken"]))
            }
        }
    }
    
    private func doesContainValidRequestId(response: NSHTTPURLResponse?, requestId: String) -> Bool
    {
        if let receivedRequestId = response?.allHeaderFields["SPH-Request-ID"] as? String where receivedRequestId == requestId
        {
            return true
        }
        println("Error: received requestID did not match.")
        return false
    }
}

