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
    
    func encryptionKey(transactionId: TransactionId, completion: @escaping (Result<EncryptionKey, NetworkError>) -> Void) {
        PaymentHighwayEndpoint.encryptionKey(merchantId: merchantId,
                                              accountId: accountId,
                                              transactionId: transactionId)
                               .getJson(completion: completion)
    }
    
    func tokenizeTransaction(
        transactionId: TransactionId,
        cardData: CardData,
        encryptionKey: EncryptionKey,
        completion: @escaping (Result<ApiResult, NetworkError>) -> Void) {
        
        // Encrypt card data
        let jsonCardData = [
            "expiry_month": cardData.expiryDate.month,
            "expiry_year": cardData.expiryDate.year,
            "cvc" : cardData.cvc,
            "pan" : cardData.pan]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonCardData),
            let data = String(data: jsonData, encoding: .utf8),
            let encryptedCardData = encryptWithRsaAes(data, certificateBase64Der: encryptionKey.key) else {
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
                              .postJson(completion: completion)
    }
}
