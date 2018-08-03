//
//  ApiResult.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 05/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

public struct ApiResultInfo: Decodable {
    public let code: Int
    public let message: String
}

public struct ApiResult: Decodable {
    public let result: ApiResultInfo
}
