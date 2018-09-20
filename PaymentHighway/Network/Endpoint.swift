//
//  Endpoint.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Alamofire

public typealias URLResponseChecker = (_ httpUrlResponse: HTTPURLResponse?, _ data: Data?) -> NetworkError?

func defaultURLResponseChecker(_ httpUrlResponse: HTTPURLResponse?, _ data: Data?) -> NetworkError? {
    var errorResult: NetworkError? = .unknown
    guard let httpUrlResponse = httpUrlResponse else { return errorResult }
    switch httpUrlResponse.statusCode {
    case 200..<300:
        if let dataResponse = data,
            let responseData = try? JSONDecoder().decode(ApiResult.self, from: dataResponse),
            responseData.result.code != ApiResult.success {
            errorResult = NetworkError.internalError(responseData.result.code, responseData.result.message)
        } else {
            errorResult = nil
        }
    case 400..<500:
        errorResult = NetworkError.clientError(httpUrlResponse.statusCode)
    case 500..<600:
        errorResult = NetworkError.serverError(httpUrlResponse.statusCode)
    default:
        errorResult = NetworkError.unexpectedStatusCode(httpUrlResponse)
    }
    return errorResult
}

/// Basic network abstraction on top of Alamofire to define custom endpoint
///
public protocol Endpoint: URLConvertible {
    
    /// Endpoint base URL
    var baseURL: URL { get }
    
    /// Optional endpoint path
    var path: String? { get }

    /// Optional endpoint parameters
    /// Default alamofire `JSONEncoding` is used
    ///
    /// - seealso: Alamofire `JSONEncoding`
    var parameters: Parameters? { get }
    
    /// Optional endpoint query parameters
    var queryParameters: [URLQueryItem]? { get }
    
    /// Optional Alamofire RequestAdapter
    ///
    /// - seealso: Alamofire `RequestAdapter`
    var requestAdapter: RequestAdapter? { get }
    
    /// Alamofire session manager
    ///
    /// - seealso: Alamofire `SessionManager`
    var sessionManager: SessionManager { get }
    
    /// Provide function for the url response checker
    ///
    var urlResponseChecker: URLResponseChecker { get }
    
    /// REST get: json result is decoded to given type
    ///
    /// - parameters completion: callback with `Result`
    func getJson<DataType: Decodable> (completion: @escaping (Result<DataType, NetworkError>) -> Void)

    /// REST post: json result is decoded to given type
    ///
    /// - parameters completion: callback with `Result`
    func postJson<DataType: Decodable>(completion: @escaping (Result<DataType, NetworkError>) -> Void)
    
    /// REST put: json result is decoded to given type
    ///
    /// - parameters completion: callback with `Result`
    func putJson<DataType: Decodable>(completion: @escaping (Result<DataType, NetworkError>) -> Void)
    
    /// REST get: Raw data are returned
    ///
    /// - parameters completion: callback with `Result`
    func get(completion: @escaping (Result<Data, NetworkError>) -> Void)
    
    /// REST post: Raw data are returned
    ///
    /// - parameters completion: callback with `Result`
    func post(completion: @escaping (Result<Data, NetworkError>) -> Void)
    
    /// REST put: Raw data are returned
    ///
    /// - parameters completion: callback with `Result`
    func put(completion: @escaping (Result<Data, NetworkError>) -> Void)
    
    /// REST delete: Raw data are returned
    ///
    /// - parameters completion: callback with `Result`
    func delete(completion: @escaping (Result<Data, NetworkError>) -> Void)
}

public extension Endpoint {
    
    var urlResponseChecker: URLResponseChecker {
        return defaultURLResponseChecker
    }
    
    var parameters: Parameters? {
        return nil
    }
    
    var queryParameters: [URLQueryItem]? {
        return nil
    }
    var requestAdapter: RequestAdapter? {
        return nil
    }
    
    private func addQueryParameters(_ urlComponents: URLComponents?) -> URLComponents? {
        guard let urlComponentsNoQueryParameters = urlComponents,
              let queryParameters = queryParameters else { return urlComponents }
        var mutableQueryItems: [URLQueryItem] = urlComponentsNoQueryParameters.queryItems ?? []
        for item in queryParameters {
            mutableQueryItems.append(item)
        }
        var newUrlComponents = urlComponentsNoQueryParameters
        newUrlComponents.queryItems = mutableQueryItems
        return newUrlComponents
    }
    
    func asURL() throws -> URL {
        var urlFull = baseURL
        if let path = path {
            urlFull = baseURL.appendingPathComponent(path)
        }
        guard let urlComponents = addQueryParameters(URLComponents(url: urlFull, resolvingAgainstBaseURL: true)),
              let urlReturn = urlComponents.url else {
            throw NetworkError.invalidURL(urlFull.absoluteString)
        }
        return urlReturn
    }
    
    var sessionManager: SessionManager {
        let sessionManagerResult = SessionManager.default
        sessionManagerResult.adapter = requestAdapter
        return sessionManagerResult
    }
    
    private func execRequest<DataType: Decodable> (_ method: Alamofire.HTTPMethod, completion: @escaping (Result<DataType, NetworkError>) -> Void) {
        sessionManager.request(self,
                               method: method,
                               parameters: self.parameters,
                               encoding: JSONEncoding.default).responseData { response in
            switch response.result {
            case .success(let data):
                if let error = self.urlResponseChecker(response.response, data) {
                    completion(.failure(error))
                    return
                }
                let dataNotEmpty: Data = data.count == 0 ? "{}".data(using: .utf8)! : data
                if let responseData = try? JSONDecoder().decode(DataType.self, from: dataNotEmpty) {
                    completion(.success(responseData))
                } else {
                    completion(.failure(.invalidJson))
                }
            case .failure(let error):
                completion(.failure(.requestError(error)))
            }
        }
    }
    
    func getJson<DataType: Decodable> (completion: @escaping (Result<DataType, NetworkError>) -> Void) {
        execRequest(.get, completion: completion)
    }
    
    func postJson<DataType: Decodable>(completion: @escaping (Result<DataType, NetworkError>) -> Void) {
        execRequest(.post, completion: completion)
    }
    
    func putJson<DataType: Decodable>(completion: @escaping (Result<DataType, NetworkError>) -> Void) {
        execRequest(.post, completion: completion)
    }
    
    private func execRequestData(_ method: Alamofire.HTTPMethod, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        sessionManager.request(self,
                               method: method,
                               parameters: self.parameters,
                               encoding: JSONEncoding.default).responseData { response in
            switch response.result {
            case .success(let data):
                if let error = self.urlResponseChecker(response.response, data) {
                    completion(.failure(error))
                } else {
                    completion(.success(data))
                }
            case .failure(let error):
                completion(.failure(.requestError(error)))
            }
        }
    }
    
    func get(completion: @escaping (Result<Data, NetworkError>) -> Void) {
        execRequestData(.get, completion: completion)
    }
    
    func post(completion: @escaping (Result<Data, NetworkError>) -> Void) {
        execRequest(.post, completion: completion)
    }
    
    func put(completion: @escaping (Result<Data, NetworkError>) -> Void) {
        execRequest(.post, completion: completion)
    }
    
    func delete(completion: @escaping (Result<Data, NetworkError>) -> Void) {
        execRequest(.delete, completion: completion)
    }
}
