//
//  Endpoint.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 03/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Alamofire

public protocol ResponseChecker {
    func checkResponse(_ httpUrlResponse: HTTPURLResponse?, _ data: Any) -> NetworkError?
}

public protocol Endpoint: URLConvertible, ResponseChecker {
    var baseURL: URL { get }
    var path: String? { get }
    var parameters: Parameters? { get }
    var queryParameters: [URLQueryItem]? { get }
    var requestAdapter: RequestAdapter? { get }
    var sessionManager: SessionManager { get }
    
    var responseChecker: ResponseChecker { get }
    
    func checkResponse(_ httpUrlResponse: HTTPURLResponse?, _ data: Any) -> NetworkError?
}

public extension Endpoint {
    
    var responseChecker: ResponseChecker { return self }
    
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
    
    func checkResponse(_ httpUrlResponse: HTTPURLResponse?, _ data: Any) -> NetworkError? {
        var errorResult: NetworkError? = .unknown
        guard let httpUrlResponse = httpUrlResponse else { return errorResult }
        switch httpUrlResponse.statusCode {
        case 200..<300:
            errorResult = nil
        case 400..<500:
            errorResult = NetworkError.clientError(httpUrlResponse.statusCode)
        case 500..<600:
            errorResult = NetworkError.serverError(httpUrlResponse.statusCode)
        default:
            errorResult = NetworkError.unexpectedStatusCode(httpUrlResponse)
        }
        return errorResult
    }
    
    private func execRequest<DataType: Decodable> (_ method: Alamofire.HTTPMethod, completion: @escaping (Result<DataType, NetworkError>) -> Void) {
        sessionManager.request(self,
                               method: method,
                               parameters: self.parameters,
                               encoding: JSONEncoding.default).responseString { response in
            switch response.result {
            case .success(let jsonString):
                if let error = self.checkResponse(response.response, jsonString) {
                    completion(.failure(error))
                    return
                }
                let jsonStringNotEmpty = jsonString.isEmpty ? "{}" : jsonString
                if let data = jsonStringNotEmpty.data(using: .utf8),
                    let responseData = try? JSONDecoder().decode(DataType.self, from: data) {
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
    
    func post<DataType: Decodable>(completion: @escaping (Result<DataType, NetworkError>) -> Void) {
        execRequest(.post, completion: completion)
    }
}
