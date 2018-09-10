//
//  PaymentContextSpec.swift
//  PaymentHighwayTests
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Quick
import Nimble
import OHHTTPStubs

@testable import PaymentHighway

let merchantIdTest = MerchantId(id: "1234567890")
let accountIdTest = AccountId(id: "0987654321")
let transactionIdTest = TransactionId(id: "111222333444555666777888999000")

struct ServerTypeTest: ServerType {
    public static var baseURL: String { return "https://this.is.the.baseurl.test/" }
}

protocol MyTestError : Error & Equatable {}

enum ErrorTest: Error {
    case rejected
    case invalid
    case networkError(String)
    case systemError(Error)
}

extension ErrorTest: Equatable {
    static func == (lhs: ErrorTest, rhs: ErrorTest) -> Bool {
        switch (lhs, rhs) {
        case let (.networkError(nlhs), .networkError(nrhs)):
            return nlhs == nrhs
        case (.rejected, .rejected),
             (.invalid, .invalid):
            return true
        default:
            return false
        }
    }
}

class BackendAdapterMock: BackendAdapter {
    
    let transactionIdResult: Result<TransactionId, ErrorTest>
    let cardAddedResult: Result<String, ErrorTest>
    
    init(transactionIdResult: Result<TransactionId, ErrorTest> = Result(value: transactionIdTest),
         cardAddedResult: Result<String, ErrorTest> = Result(value: "OK")) {
        self.transactionIdResult = transactionIdResult
        self.cardAddedResult = cardAddedResult
    }
    
    private func timer(withTimeInterval timeInterval: TimeInterval, _ block: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + timeInterval,
            execute: block)
    }
    
    func getTransactionId(completion: @escaping (Result<TransactionId, ErrorTest>) -> Void) {
        timer(withTimeInterval: 1) { () in
            completion(self.transactionIdResult)
        }
    }
    
    func addCardCompleted(transactionId: TransactionId, completion: @escaping (Result<String, ErrorTest>) -> Void) {
        timer(withTimeInterval: 1) { () in
            completion(self.cardAddedResult)
        }
    }
    
    func mapError(error: Error) -> ErrorTest {
        return .systemError(error)
    }

}

let creditCardNumber = "5422 3333 4444 5555"
let cvcTest = "123"
let expirationDataTest = ExpirationDate(month: "11", year: "22")
let cardDataTest = CardData(pan: creditCardNumber, cvc: cvcTest, expirationDate: expirationDataTest!)
let paymentConfig = PaymentConfig(merchantId: merchantIdTest, accountId: accountIdTest)
// swiftlint:disable line_length
let cardKey = "MIIDlTCCAn0CBwDvPs8AcHAwDQYJKoZIhvcNAQELBQAwgZ0xCzAJBgNVBAYTAkZJMRkwFwYDVQQIDBBTb3V0aGVybiBGaW5sYW5kMREwDwYDVQQHDAhIZWxzaW5raTETMBEGA1UECgwKU29saW5vciBPeTEYMBYGA1UECwwPUGF5bWVudCBIaWdod2F5MTEwLwYDVQQDDChTUEggc3RhZ2luZyBtb2JpbGUgQ2VydGlmaWNhdGUgQXV0aG9yaXR5MCAXDTE1MDcwMzEwMDI0NVoYDzIwNjUwNjIwMTAwMjQ1WjB7MQswCQYDVQQGEwJGSTEZMBcGA1UECAwQU291dGhlcm4gRmlubGFuZDERMA8GA1UEBwwISGVsc2lua2kxEzARBgNVBAoMClNvbGlub3IgT3kxGDAWBgNVBAsMD1BheW1lbnQgSGlnaHdheTEPMA0GA1UEAwwGbW9iaWxlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwTNgR67GUJNODCyJ6W8yRFzIN99DG3o7xMiF+ogzbXL/07d32diFTZF3MsuGQjEPg+aoUCgp7ly4dG0GBQi7HdpNYeY1ATdBiWit8FGl9Iu++kBDGbOxyvj1hhlvyem/lNsh0H06oODavXKCjE6NjRMgKTlu69d+ZRSQBbCxx8KAS8ApVy5cSwym8CkfxDvLyBFU+EIsuYXJ6zCpHZmBPiVM2Ev0YpNsIl/C5I25UKqIokiSpLZC3gd0dwyD7H0gJEg/TVL9dhjzKSkYkyVOM9T/W0w4x/jQrm33+1dyzvUw7TBH+Hbiv3BE1qAnSGVHtlzt2gcApKJWI38JqOev6wIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQAePsPR/zrYcEg1s59htZeghN+2HwkHl0wWHy5YI8EyqnjkFAE+oaYTizNH+Estm0k8DT5X3OIi1iCHg9YEHLZhYgmMkWGCpDKu7PQ5CCvEwz3pQuIfPXUwaiXcMu6HKpHm4xs1ZMOnmEhlk1GQXK5ksegXFhGgXK1BVKuFDNC6ST78GvEcURa0RaZA1Q6EPjpJw84PFP6l8wB2+eZybX9OufjqFSktC5mBbvhB+r9tQ/FNb0LdSmX+zCNS2k4mVSZ9OWT67D/e3XJCCC055mDAB2MEZULOfl3wQG10FU+hGJqN6VPmstGKqCJlSRQKFlBXSmLVYFCUD6gH4jHl2mnL"

let networkErrorTest: ErrorTest = .networkError("FAILED")

// swiftlint:disable force_try function_body_length
class PaymentContextSpec: QuickSpec {
    
    func addEncryptionKeyStub(statusCode: Int32? = nil) {
        let url = try! PaymentHighwayEndpoint.encryptionKey(merchantId: merchantIdTest, accountId: accountIdTest, transactionId: transactionIdTest).asURL()
        if let statusCode = statusCode {
            stub(condition: isHost(url.host!) && isPath(url.path)) { _ in
                let obj = ["error": statusCode]
                return OHHTTPStubsResponse(jsonObject: obj, statusCode: statusCode, headers: nil)
            }
        } else {
            stub(condition: isHost(url.host!) && isPath(url.path)) { _ in
                let obj = ["key": cardKey]
                return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: nil)
            }
        }
    }
    
    func addTokenizeTransactionStub(statusCode: Int32? = nil) {
        let url = try! PaymentHighwayEndpoint.tokenizeTransaction(merchantId: merchantIdTest, accountId: accountIdTest, transactionId: transactionIdTest, parameters: [:]).asURL()
        if let statusCode = statusCode {
            stub(condition: isHost(url.host!) && isPath(url.path)) { _ in
                let obj = ["error": statusCode]
                return OHHTTPStubsResponse(jsonObject: obj, statusCode: statusCode, headers: nil)
            }
        } else {
            stub(condition: isHost(url.host!) && isPath(url.path)) { _ in
                let obj = ["result": ["code":100, "message": "OK"]]
                return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: nil)
            }
        }
    }
    
    override func spec() {
        
        afterEach {
            OHHTTPStubs.removeAllStubs()
        }
        
        describe("With Payment Context") {
            
            it("we should get success") {
                self.addEncryptionKeyStub()
                self.addTokenizeTransactionStub()
                var resultTest = ""
                let paymentContext = PaymentContext(config: paymentConfig, backendAdapter: BackendAdapterMock())
                paymentContext.addCard(card: cardDataTest) { result in
                    if case .success(let value) = result {
                        resultTest = value
                    }
                }
                expect(resultTest).toEventually(contain("OK"), timeout: 3)
            }
            
            it("we should get error from backend adapter getting transactionId") {
                var resultError: ErrorTest = .invalid
                let paymentContext = PaymentContext(config: paymentConfig,
                                                    backendAdapter: BackendAdapterMock(transactionIdResult: .failure(networkErrorTest)))
                paymentContext.addCard(card: cardDataTest) { result in
                     if case .failure(let error) = result {
                        resultError = error
                    }
                }
                expect(resultError).toEventually(equal(networkErrorTest), timeout: 3)
            }
            
            it("we should get error from backend adapter cardAdded") {
                self.addEncryptionKeyStub()
                self.addTokenizeTransactionStub()
                var resultError: ErrorTest = .invalid
                let paymentContext = PaymentContext(config: paymentConfig,
                                                    backendAdapter: BackendAdapterMock( cardAddedResult: .failure(networkErrorTest)))
                paymentContext.addCard(card: cardDataTest) { result in
                    if case .failure(let error) = result {
                        resultError = error
                    }
                }
                expect(resultError).toEventually(equal(networkErrorTest), timeout: 3)
            }
            
            it("we should get error error getting Transaction Key") {
                self.addEncryptionKeyStub(statusCode: 400)
                var resultStatusCode = 0
                let paymentContext = PaymentContext(config: paymentConfig, backendAdapter: BackendAdapterMock())
                paymentContext.addCard(card: cardDataTest) { result in
                    if case .failure(let error) = result,
                       case .systemError(let systemError) = error,
                       let networkError =  systemError as? NetworkError,
                       case .clientError(let statusCode) = networkError {
                         resultStatusCode = statusCode
                    }
                }
                expect(resultStatusCode).toEventually(equal(400), timeout: 3)
            }

            it("we should get error error in Tokenisation") {
                self.addEncryptionKeyStub()
                self.addTokenizeTransactionStub(statusCode: 401)
                var resultStatusCode = 0
                let paymentContext = PaymentContext(config: paymentConfig, backendAdapter: BackendAdapterMock())
                paymentContext.addCard(card: cardDataTest) { result in
                    if case .failure(let error) = result,
                        case .systemError(let systemError) = error,
                        let networkError =  systemError as? NetworkError,
                        case .clientError(let statusCode) = networkError {
                        resultStatusCode = statusCode
                    }
                }
                expect(resultStatusCode).toEventually(equal(401), timeout: 3)
            }
        }
    }
}
