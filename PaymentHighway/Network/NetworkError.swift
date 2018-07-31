//
//  NetworkError.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 03/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Alamofire

public enum NetworkError: Error {
    case unknown
    case invalidJson
    case invalidURL(String)
    case clientError(Int)
    case serverError(Int)
    case requestError(Error)
    case unexpectedStatusCode(HTTPURLResponse)
    case dataError(String?)
    case internalError(Int, String)
}
