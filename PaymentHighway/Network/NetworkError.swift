//
//  NetworkError.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Alamofire

/// Enum with the possible network errors
public enum NetworkError: Error {
    
    /// Unknown error
    case unknown
    
    /// Invalid Json
    case invalidJson
    
    /// Invalid URL
    ///
    /// - parameters url: provide the invalid url
    case invalidURL(String)
    
    /// Client error: the default checked implementation raise this error for status code 4xx
    ///
    /// - parameters status code: provide the status code
    case clientError(Int)

    /// Server error: the default checked implementation raise this error for status code 5xx
    ///
    /// - parameters status code: provide the status code
    case serverError(Int)
    
    /// Alamofire request error
    ///
    /// - parameters error: error from alamofire
    case requestError(Error)

    /// Received an unexpected status code
    ///
    /// - parameters response: HTTPURLResponse
    case unexpectedStatusCode(HTTPURLResponse)

    /// Generic invalid data error. Used in case encrypt data fail
    ///
    /// - parameters data: string trying to encrypt
    case dataError(String?)

    /// Wrap error from backend
    ///
    /// - parameters error: error code from server
    /// - parameters message: message error from server
    case internalError(Int, String)
}

extension NetworkError: CustomStringConvertible {
    /// A description of the error
    public var description: String {
        switch self {
        case .unknown: return "Unknown error."
        case .invalidJson: return "Invalid JSON."
        case .invalidURL(let message): return "Invalid URL: \(message)."
        case .clientError(let statusCode): return "Client error: \(statusCode)."
        case .serverError(let statusCode): return "Server error: \(statusCode)."
        case .requestError(let error): return "Request error: \(error)"
        case .unexpectedStatusCode(let httpUrlResponse): return "Unexpected Status Code: \(httpUrlResponse.statusCode)"
        case .dataError(let message): return "Data error: \(message ?? "?")"
        case .internalError(let code, let message): return "Internal Error: \n\(code) - \(message)"
        }
    }
}
