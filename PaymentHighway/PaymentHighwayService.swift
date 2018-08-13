//
//  PaymentHighwayServive.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

class PaymentHighwayService {
    
    private let merchantId: MerchantId
    private let accountId: AccountId
    
    init(merchantId: MerchantId, accountId: AccountId) {
        self.merchantId = merchantId
        self.accountId = accountId
    }
    
    func transactionKey(transactionId: TransactionId, completion: @escaping (Result<TransactionKey, NetworkError>) -> Void) {
        PaymentHighwayEndpoint.transactionKey(merchantId: merchantId,
                                              accountId: accountId,
                                              transactionId: transactionId)
                              .getJson {(result: Result<TransactionKey, NetworkError>) in
            switch result {
            case .success(let transactionKey):
                completion(.success(transactionKey))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // (sph)/mobile/(transactionId)/tokenize
    func tokenizeTransaction(
        transactionId: TransactionId,
        cardData: CardData,
        transactionKey: TransactionKey,
        completion: @escaping (Result<ApiResult, NetworkError>) -> Void) {
        
        // Encrypt card data
        let jsonCardData = [
            "expiry_month": cardData.expirationDate.month,
            "expiry_year": cardData.expirationDate.year,
            "cvc" : cardData.cvc,
            "pan" : cardData.pan]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonCardData),
            let data = String(data: jsonData, encoding: .utf8),
            let encryptedCardData = encryptWithRsaAes(data, certificateBase64Der: transactionKey.key) else {
                completion(.failure(.dataError("Could not encrypt data during network.tokenize.")))
                return
        }
        
        // Create JSON payload
        let parameters: [String : Any] = [
            "encrypted" : encryptedCardData.encryptedBase64Message,
            "key" : [
                "key" : encryptedCardData.encryptedBase64Key,
                "iv" : encryptedCardData.iv
            ]
        ]
        
        PaymentHighwayEndpoint.tokenizeTransaction(merchantId: merchantId, accountId: accountId, transactionId: transactionId, parameters: parameters)
                              .post {(result: Result<ApiResult, NetworkError>) in
            switch result {
            case .success(let apiResult):
                completion(.success(apiResult))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
}
