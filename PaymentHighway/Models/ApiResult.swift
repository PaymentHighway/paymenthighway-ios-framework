//
//  ApiResult.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

/// Json mapping of the result data from the Payment Highway API
///
public struct ApiResult: Decodable {

    public static let success = 100
    
    public let result: ApiResultInfo
}

public struct ApiResultInfo: Decodable {
    public let code: Int
    public let message: String
}
