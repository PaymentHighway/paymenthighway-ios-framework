//
//  EndpointSpec.swift
//  PaymentHighwayTests
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Quick
import Nimble
import Alamofire
import OHHTTPStubs

@testable import PaymentHighway

struct TestResponseResult: Decodable {
    let name: String
    let city: String
    let age: String
}

extension TestResponseResult: Equatable {
    static func == (lhs: TestResponseResult, rhs: TestResponseResult) -> Bool {
        return lhs.name == rhs.name &&
               lhs.city == rhs.city &&
               lhs.age == rhs.age
    }
}

enum TestError : Error {
    case noError
    case testError
}

let headerKeyId = "TEST-id"
let headerKeyAge = "TEST-age"
class TestRequestAdaptor: RequestAdapter {
    
    private let id: String
    private let age: Int?
    
    init(id: String, age: Int? = nil) {
        self.id = id
        self.age = age
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var request = urlRequest
        request.addValue(id, forHTTPHeaderField: headerKeyId)
        if let age = age {
            request.addValue(String(age), forHTTPHeaderField: headerKeyAge)
        }
        return request
    }
}

let endpoint1QueryParameters: [URLQueryItem]? = [
    URLQueryItem(name: "param0", value: nil),
    URLQueryItem(name: "param1", value: "valueParam1"),
    URLQueryItem(name: "param2", value: "value param2")
]

let endpoint2Parameters: [String: String] = [
    "value1": "value 1",
    "value2": "value 2"
]

enum TestEndpoint : Endpoint {
    case endpoint1(user: String, id: String)
    case endpoint2(id: String, age: Int)

    var queryParameters: [URLQueryItem]? {
        if case .endpoint1 = self {
            return endpoint1QueryParameters
        }
        return nil
    }
    
    var parameters: Parameters? {
        if case .endpoint2 = self {
            return endpoint2Parameters
        }
        return nil
    }
    
    var baseURL: URL {
        return URL(string: "https://test.paymenthighway.io")!
    }
        
    var path: String? {
        switch self {
        case .endpoint1(let user, _):
            return "/endpoint1/\(user)"
        case .endpoint2:
            return "/endpoint2"
        }
    }
    
    var requestAdapter: RequestAdapter? {
        switch self {
        case .endpoint1(_, let id):
            return TestRequestAdaptor(id: id)
        case .endpoint2(let id, let age):
            return TestRequestAdaptor(id: id, age: age)
        }
    }
}

let userTest = "paymenthighway"
let idTest = "11223344556677889900"
let ageTest = 33

// swiftlint:disable function_body_length force_cast force_try cyclomatic_complexity
class EndpointSpec: QuickSpec {
    
    private var endpoint1: TestEndpoint {
        return TestEndpoint.endpoint1(user: userTest, id: idTest)
    }

    private var endpoint1URL: URL {
        return try! endpoint1.asURL()
    }
    
    private var endpoint2: TestEndpoint {
        return TestEndpoint.endpoint2(id: idTest, age: ageTest)
    }
    
    private var endpoint2URL: URL {
        return try! endpoint2.asURL()
    }
    
    override func spec() {
        
        // move this in string extension test?
        describe("An Endpoint") {
            
            it("should return success") {
                
                stub(condition: isHost(self.endpoint1URL.host!) && isPath(self.endpoint1URL.path)) { _ in
                    let obj = ["name":"Lauri", "city": "Helsinki", "age": "30"]
                    return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: nil)
                }
                
                var responseResult = TestResponseResult(name: "", city: "", age: "")
                let expectedResult = TestResponseResult(name: "Lauri", city: "Helsinki", age: "30")
                
                self.endpoint1.getJson { (result: PaymentHighway.Result<TestResponseResult, NetworkError>) in
                    switch result {
                    case .success(let value):
                        responseResult = value
                    case .failure(let error):
                        fail("Got unexpected failure error:\(error)")
                    }
                }
                
                expect(responseResult).toEventually(equal(expectedResult), timeout: 3)
            }

            it("should return success raw data") {
                
                let expectedData = "1234567890".data(using: .utf8)!
                
                stub(condition: isHost(self.endpoint1URL.host!) && isPath(self.endpoint1URL.path)) { _ in
                    return OHHTTPStubsResponse(data: expectedData, statusCode: 200, headers: nil)
                }
                
                var responseResult: Data?
                
                self.endpoint1.get { (result: PaymentHighway.Result<Data, NetworkError>) in
                    switch result {
                    case .success(let value):
                        responseResult = value
                    case .failure(let error):
                        fail("Got unexpected failure error:\(error)")
                    }
                }
                
                expect(responseResult).toEventually(equal(expectedData), timeout: 3)
            }
            
            it("should return success raw data nill") {
                
                stub(condition: isHost(self.endpoint1URL.host!) && isPath(self.endpoint1URL.path)) { _ in
                    return OHHTTPStubsResponse(data: "".data(using: .utf8)!, statusCode: 200, headers: nil)
                }
                
                var responseOk = false
                
                self.endpoint1.get { (result: PaymentHighway.Result<Data, NetworkError>) in
                    switch result {
                    case .success(let value):
                        expect(value.count).to(equal(0))
                        responseOk = true
                    case .failure(let error):
                        fail("Got unexpected failure error:\(error)")
                    }
                }
                
                expect(responseOk).toEventually(equal(true), timeout: 3)
            }
            
            it("should return Error") {
                
                stub(condition: isHost(self.endpoint1URL.host!) && isPath(self.endpoint1URL.path)) { _ in
                    return OHHTTPStubsResponse(error: TestError.testError)
                }
                
                var responseError: TestError = .noError
                
                self.endpoint1.getJson { (result: PaymentHighway.Result<TestResponseResult, NetworkError>) in
                    switch result {
                    case .success(let value):
                        fail("Got unexpected success:\(value)")
                    case .failure(let error):
                        if case .requestError(let networkError) = error {
                            responseError = networkError as! TestError
                        } else {
                            fail("Got unexpected errot:\(error)")
                        }
                    }
                }
                
                expect(responseError).toEventually(equal(TestError.testError), timeout: 3)
            }
            
            it("should return 400") {
                
                stub(condition: isHost(self.endpoint1URL.host!) && isPath(self.endpoint1URL.path)) { _ in
                    let obj = ["error":"123", "message": "error message"]
                    return OHHTTPStubsResponse(jsonObject: obj, statusCode: 400, headers: nil)
                }
                
                var responsestatusCode = 0
                
                self.endpoint1.getJson { (result: PaymentHighway.Result<TestResponseResult, NetworkError>) in
                    switch result {
                    case .success(let value):
                        fail("Got unexpected success:\(value)")
                    case .failure(let error):
                        if case .clientError(let statusCode) = error {
                            responsestatusCode = statusCode
                        } else {
                            fail("Got unexpected errot:\(error)")
                        }
                    }
                }
                
                expect(responsestatusCode).toEventually(equal(400), timeout: 3)
            }
            
            it("should return success no data empty json") {
                
                stub(condition: isHost(self.endpoint1URL.host!) && isPath(self.endpoint1URL.path)) { _ in
                    let obj:[String: String] = [:]
                    return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: nil)
                }
                
                var responseOk = false
                
                self.endpoint1.getJson { (result: PaymentHighway.Result<NoData, NetworkError>) in
                    switch result {
                    case .success:
                        responseOk = true
                    case .failure(let error):
                        fail("Got unexpected errot:\(error)")
                    }
                }
                
                expect(responseOk).toEventually(equal(true), timeout: 3)
            }

            it("should return success data nil") {
                
                stub(condition: isHost(self.endpoint1URL.host!) && isPath(self.endpoint1URL.path)) { _ in
                    return OHHTTPStubsResponse(data: "".data(using: .utf8)!, statusCode: 200, headers: nil)
                }
                
                var responseOk = false
                
                self.endpoint1.getJson { (result: PaymentHighway.Result<NoData, NetworkError>) in
                    switch result {
                    case .success:
                        responseOk = true
                    case .failure(let error):
                        fail("Got unexpected errot:\(error)")
                    }
                }
                
                expect(responseOk).toEventually(equal(true), timeout: 3)
            }

            it("should have query parameters") {
                
                if let queryItems = URLComponents(string: self.endpoint1URL.absoluteString)?.queryItems,
                   endpoint1QueryParameters == queryItems {
                    return
                }
                fail("invalid query parameters")

            }
            
            it("should have http body and headers") {
                var httpBody: Data?
                var headers: [String: String]?
                
                stub(condition: isHost(self.endpoint2URL.host!) && isPath(self.endpoint2URL.path)) { request in
                    httpBody = request.ohhttpStubs_httpBody
                    headers = request.allHTTPHeaderFields
                    return OHHTTPStubsResponse(data: "".data(using: .utf8)!, statusCode: 200, headers: nil)
                }
                var responseOk = false
                
                self.endpoint2.postJson { (result: PaymentHighway.Result<NoData, NetworkError>) in
                    switch result {
                    case .success:
                        responseOk = true
                    case .failure(let error):
                        fail("Got unexpected failure error:\(error)")
                    }
                }
                
                expect(responseOk).toEventually(equal(true), timeout: 3)
                if let bodyDictionary = try? JSONSerialization.jsonObject(with: httpBody!) as! [String: String],
                   let headers = headers {
                    expect(bodyDictionary.count).to(equal(endpoint2Parameters.count))
                    expect(bodyDictionary).to(equal(endpoint2Parameters))
                    expect(headers[headerKeyId]).to(equal(idTest))
                    expect(headers[headerKeyAge]).to(equal(String(ageTest)))
                } else {
                    fail("body or header empty")
                }
            }
        }
    }
}
