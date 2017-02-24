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


class SPHRequestAdapter: RequestAdapter {
    let merchantId: String
    let accountId: String
    private(set) var hostname: String
    private(set) var lastRequestId: String = ""
    
    init(merchantId: String, accountId: String, hostname: String) {
        self.merchantId = merchantId
        self.accountId = accountId
        self.hostname = hostname
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var request = urlRequest
        
        // Prepend baseURL
        let requestURL = hostname.appending(request.url!.absoluteString)
        request.url = URL(string: requestURL)
        
        // Generate request id
        lastRequestId = getRequestId()
        
        // Inject additional headers
        request.addValue(merchantId, forHTTPHeaderField: "SPH-Merchant")
        request.addValue(accountId, forHTTPHeaderField: "SPH-Account")
        request.addValue(lastRequestId, forHTTPHeaderField: "SPH-Request-ID")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let date = Date()
        let formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'";
        formatter.timeZone = TimeZone(abbreviation: "UTC");
        let utcTimeZoneStr = formatter.string(from: date);
        
        request.addValue(utcTimeZoneStr, forHTTPHeaderField: "SPH-Timestamp")
        
        return request
    }
}


enum SPHRouter: URLRequestConvertible {
    case transactionId
    case transactionKey(String)
    case tokenizeTransaction(String)
    
    var method: HTTPMethod {
        switch self {
        case .transactionId:
            return .get
        case .transactionKey, .tokenizeTransaction:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .transactionId:
            return "/mobile-key"
        case .transactionKey(let transactionId):
            return "/mobile/\(transactionId)/key"
        case .tokenizeTransaction(let transactionId):
            return "/mobile/\(transactionId)/tokenize"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: path)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }
}


open class SPHNetworking {
    fileprivate var manager: Alamofire.SessionManager!
    fileprivate var adapter: SPHRequestAdapter!
    
    private enum errorCode: Int {
        case invalidResponse, unknown
    }
    
    public init(merchantId: String, accountId: String, hostname: String) {
        // Create request adapter that injects merchant id and baseurl
        adapter = SPHRequestAdapter(merchantId: merchantId, accountId: accountId, hostname: hostname)
        
        // Create HTTP session manager
        manager = SessionManager()
        manager.adapter = adapter
    }
    
    open func transactionId(success: @escaping (String) -> (), failure: @escaping (Error) -> ()) -> () {
        manager.request(SPHRouter.transactionId).responseJSON { response in
            // Check for errors
            if let error = response.result.error {
                return failure(error)
            }
            
            // Fetch the JSON response
            guard let json = response.result.value as AnyObject? else {
                return failure(NSError(
                    domain: ClutchDomains.Default,
                    code: errorCode.unknown.rawValue,
                    userInfo: ["errorReason" : "Unknown error during helperGetTransactionId"]
                ))
            }
            
            // Find transaction ID from the JSON response
            let transactionId = JSON(json)["id"].stringValue
            
            // Invalid transaction ID check
            if transactionId.isEmpty {
                return failure(NSError(
                    domain: ClutchDomains.Default,
                    code: errorCode.invalidResponse.rawValue,
                    userInfo: ["errorReason" : "Server did not return a valid transaction id."]
                ))
            }
            
            return success(transactionId)
        }.responseString { response in
            print("STRING RESPONSE: \(response.value)")
        }
    }
    
    open func transactionKey(transactionId: String, success: @escaping (String) -> (), failure: @escaping (Error) -> ()) -> () {
        manager.request(SPHRouter.transactionKey(transactionId)).responseJSON { response in
            if response.result.error != nil {
                // Check for errors
                if let error = response.result.error {
                    return failure(error)
                }
            }
            
            // Fetch the JSON response
            guard let json = response.result.value as AnyObject? else {
                return failure(NSError(
                    domain: ClutchDomains.Default,
                    code: errorCode.unknown.rawValue,
                    userInfo: ["errorReason" : "Unknown error during transactionKey"]
                ))
            }
            
            // Find transaction ID from the JSON response
            let transactionKey = JSON(json)["key"].stringValue
            
            // Validate request ID
            guard let receivedRequestId = response.response?.allHeaderFields["SPH-Request-ID"] as? String, receivedRequestId == self.adapter.lastRequestId else {
                return failure(NSError(
                    domain: ClutchDomains.Default,
                    code: errorCode.invalidResponse.rawValue,
                    userInfo: ["errorReason" : "Server did not return a valid requestId."]
                ))
            }
            
            // Validate transaction key
            if transactionKey.isEmpty {
                return failure(NSError(
                    domain: ClutchDomains.Default,
                    code: errorCode.invalidResponse.rawValue,
                    userInfo: ["errorReason" : "Server did not return a transaction key."]
                ))
            }
            
            return success(transactionKey)
        }.responseString { response in
            print("STRING RESPONSE: \(response.value)")
        }
    }
    
    open func transactionToken(transactionId: String, success: @escaping (String) -> (), failure: @escaping (NSError) -> ()) -> () {
        
    }
    
    open func tokenizeTransaction(transactionId: String, expiryMonth: String, expiryYear: String, cvc: String, pan: String, certificateBase64Der: String, success: @escaping (String) -> (), failure: @escaping (NSError) -> ()) -> () {
        
    }
}

/*
open class Networking {
    
    fileprivate var manager: Alamofire.SessionManager!
    
    open let resultStringTokenisationSuccess = "Tokenisation OK"
    
    fileprivate var mobileApiAddress: String?
    
    fileprivate let merchantId: String
    
    fileprivate let account: String
    
    public enum errorCode: Int {
        case serverResponseInvalid, unknown
    }
    
    public init(merchant: String, accountId: String, host: String) {
        mobileApiAddress = host
        merchantId = merchant
        account = accountId
        manager = getManagerWithDefaults(merchant, account: accountId)
    }
    
    fileprivate func getManagerWithDefaults(_ merchant: String, account: String) -> Alamofire.SessionManager {
        
        var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        defaultHeaders["SPH-Merchant"] = merchant
        defaultHeaders["SPH-Account"] = account
        defaultHeaders["Content-Type"] = "application/json; charset=utf-8"
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        
        return Alamofire.SessionManager(configuration: configuration)
    }
    
    fileprivate func getSphHeaders(_ requestId: String) -> [String: String]
    {
        let date = Date()
        
        let formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'";
        formatter.timeZone = TimeZone(abbreviation: "UTC");
        let utcTimeZoneStr = formatter.string(from: date);
        
        return [
            "SPH-Timestamp" : utcTimeZoneStr,
            "SPH-Request-ID" : requestId
        ]
    }
    
    open func helperGetTransactionId(_ host: String, success: @escaping (String) -> (), failure: @escaping (Error) -> ()) -> () {
        _ = getRequestId() // requestId not validated for this call
        
        manager.request("\(host)/mobile-key", method: .get).responseJSON{ response in
            if let errorMessage = response.result.error {
                print("Networking.helperGetTransactionId most likely received malformed data from server.")
                failure(errorMessage as NSError)
            } else if let json: AnyObject = response.result.value as AnyObject? {
                let transactionId = JSON(json)["id"].stringValue
                
                if transactionId.characters.count > 0
                {
                    success(transactionId)
                } else {
                    let error = NSError(domain: ClutchDomains.Default, code: errorCode.serverResponseInvalid.rawValue, userInfo: ["errorReason" : "Server did not return a valid transaction id."])
                    failure(error)
                }

            } else {
                let error = NSError(domain: ClutchDomains.Default, code: errorCode.unknown.rawValue, userInfo: ["errorReason" : "Unknown error during helperGetTransactionId"])
                failure(error)
            }
        }
    }
    
    open func getKey(_ transactionId: String, success: @escaping (String) -> (), failure: @escaping (NSError) -> ()) -> () {
        let reqId = getRequestId()
        manager.request("\(self.mobileApiAddress!)/mobile/\(transactionId)/key", headers: getSphHeaders(reqId)).responseJSON {
            (response) in
                if let errorMessage = response.result.error {
                    print("Networking.getKey most likely received malformed data from server.")
                    failure(errorMessage as NSError)
                } else if let json: AnyObject = response.result.value as AnyObject? {
                    let key = JSON(json)["key"].stringValue
                    if key.characters.count > 0 && self.doesContainValidRequestId(response.response, requestId: reqId) {
                        success(key)
                    } else {
                        let error = NSError(domain: ClutchDomains.Default, code: errorCode.serverResponseInvalid.rawValue, userInfo: ["errorReason" : "Server did not return a key or received requestId was invalid."])
                        failure(error)
                    }
                } else {
                    let error = NSError(domain: ClutchDomains.Default, code: errorCode.unknown.rawValue, userInfo: ["errorReason" : "Unknown error during getKey"])
                    failure(error)
                }
        }
    }
    
    open func tokenize(_ transactionId: String, expiryMonth: String, expiryYear: String, cvc: String, pan: String, certificateBase64Der: String, success: @escaping (String) -> (), failure: @escaping (NSError) -> ()) -> () {
        
        // Encrypt card data
        let jsonCardData = JSON(["expiry_month": expiryMonth, "expiry_year": expiryYear, "cvc" : cvc, "pan" : pan])
        
        guard let encryptedCardData = encryptWithRsaAes(jsonCardData.description, certificateBase64Der: certificateBase64Der) else {
            failure(NSError(domain: ClutchDomains.Default, code: 5, userInfo: ["errorReason" : "Could not encrypt data during network.tokenize."]))
        }
        
        // Create JSON payload
        let parameters: [String : Any] = [
            "encrypted" : encryptedCardData.encryptedBase64Message,
            "key" : [
                "key" : encryptedCardData.encryptedBase64Key,
                "iv" : encryptedCardData.iv
            ]
        ]
        
        // Request encoding
        let customEncoding: (URLRequestConvertible, [String: AnyObject]?) -> (NSURLRequest, NSError?) = { (URLRequest, parameters) in
            var urlRequest = try! URLRequest.asURLRequest()
            urlRequest.httpBody = ("\(JSON(parameters!))").data(using: .utf8, allowLossyConversion: false)
            return (urlRequest as NSURLRequest, nil)
        }
        
        let requestId = getRequestId()
        
        manager.request(<#T##url: URLConvertible##URLConvertible#>, method: <#T##HTTPMethod#>, parameters: <#T##Parameters?#>, encoding: <#T##ParameterEncoding#>, headers: <#T##HTTPHeaders?#>)
        manager.request("\(self.mobileApiAddress!)/mobile/\(transactionId)/tokenize", method: .post, parameters: parameters as? [String : AnyObject], encoding: .Custom(customEncoding), headers: getSphHeaders(requestId)).responseJSON { (response) in
            
            if let errorMessage = response.result.error {
                print("Networking.tokenize most likely received malformed data from server.")
                failure(errorMessage)
            } else if let json: AnyObject = response.result.value {
                let code = JSON(json)["result"]["code"].int
                let message = JSON(json)["result"]["message"].stringValue
                
                if code == 100 && message == "OK" && self.doesContainValidRequestId(response.response, requestId: reqId) {
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
    
    open func helperGetToken(_ host: String, transactionId: String, success: @escaping (String) -> (), failure: @escaping (NSError) -> ()) -> () {
        let reqId = getRequestId() // request id not validated for this call
        manager.request("\(host)/tokenization/\(transactionId)", method: .get, headers: getSphHeaders(reqId)).responseJSON { (response) in
            if let errorMessage = response.result.error {
                print("Networking.helperGetToken most likely received malformed data from server.")
                let error = NSError(domain: ClutchDomains.Default, code: errorCode.serverResponseInvalid.rawValue, userInfo: ["errorReason" : "Networking.helperGetToken most likely received malformed data from server."])
                failure(error)
            } else if let dataMessage: AnyObject = response.data {
                if JSON(dataMessage)["token"].stringValue.characters.count > 0
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
    
    fileprivate func doesContainValidRequestId(_ response: HTTPURLResponse?, requestId: String) -> Bool
    {
        if let receivedRequestId = response?.allHeaderFields["SPH-Request-ID"] as? String, receivedRequestId == requestId
        {
            return true
        }
        print("Error: received requestID did not match.")
        return false
    }
}

*/
