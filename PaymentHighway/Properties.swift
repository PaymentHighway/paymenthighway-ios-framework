//
//  Properties.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 02/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

protocol Properties: ServerType {
}

// swiftlint:disable force_try force_cast
class PaymentHighwayProperties: Properties {
    
    #if PH_PRODUCTION
    private static let enviroment = "production"
    #else
    public static var enviroment = "staging"
    #endif
    
    private static let BASEURLKEY = "baseURL"
    
    private static var staticBaseURL = ""
    
    private class func getPropertiesDictionary() throws -> NSDictionary {
        let phbundle = Bundle(identifier: "io.paymenthighway.PaymentHighway")
        let url = phbundle!.url(forResource: "PaymentHighway_\(enviroment)", withExtension: "plist")
        let properties = try Data(contentsOf: url!)
        return try PropertyListSerialization.propertyList(from: properties, options: [], format: nil) as! NSDictionary
    }
    
    static var baseURL: String {
        if PaymentHighwayProperties.staticBaseURL.isEmpty {
            let propertiesDic = try! getPropertiesDictionary()
            let baseURLFromDic = propertiesDic[BASEURLKEY] as! String
            PaymentHighwayProperties.staticBaseURL = baseURLFromDic
        }
        return PaymentHighwayProperties.staticBaseURL
    }
    
}
