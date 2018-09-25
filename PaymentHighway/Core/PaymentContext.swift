//
//  PH.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

/// `PaymentContext` manages all the functionality the payment context, such as adding a new payment card.
///
public class PaymentContext<BackendAdpaterType: BackendAdapter> {
    
    let backendAdapter: BackendAdpaterType
    let phService: PaymentHighwayService
    
    /// Required to initialize `PaymentContext`
    ///
    /// - parameter config: The configuration of the `PaymentContext`
    /// - parameter backendAdapter: Provide your BackendAdpater implementation
    /// - seealso: PaymentConfig
    /// - seealso: BackendAdapter
    /// - seealso: Result
    ///
    public init(config: PaymentConfig, backendAdapter: BackendAdpaterType) {
        self.backendAdapter = backendAdapter
        self.phService = PaymentHighwayService(config: config)
    }

    /// Adds a new Payment Card.
    ///
    /// - parameter card: Card to be added
    /// - parameter completion: Callback closure with the result of the operation
    /// - seealso: CardData
    /// - seealso: Result
    ///
    public func addCard(card: CardData,
                        completion: @escaping (Result<BackendAdpaterType.AddCardCompletedType, BackendAdpaterType.BackendAdapterErrorType>) -> Void) {
        backendAdapter.getTransactionId { [weak self] (resultTransactionId) in
            switch resultTransactionId {
            case .success(let transactionId):
                self?.tokenizeCard(transactionId: transactionId, card: card, completion: completion)
            case .failure(let transactionIdError):
                completion(.failure(transactionIdError))
            }
        }
    }
    
    private func tokenizeCard(transactionId: TransactionId,
                              card: CardData,
                              completion: @escaping (Result<BackendAdpaterType.AddCardCompletedType,
                                                     BackendAdpaterType.BackendAdapterErrorType>) -> Void) {
        phService.encryptionKey(transactionId: transactionId) { [weak self] (resultEncryptionKey) in
            guard let strongSelf = self else { return }
            switch resultEncryptionKey {
            case .success(let encryptionKey):
                strongSelf.performTokenizationRequest(encryptionKey: encryptionKey, transactionId: transactionId, card: card, completion: completion)
            case .failure(let encryptionKeyError):
                completion(.failure(strongSelf.backendAdapter.mapError(error: encryptionKeyError)))
            }
        }
    }
    
    private func performTokenizationRequest(encryptionKey: EncryptionKey,
                                            transactionId: TransactionId,
                                            card: CardData,
                                            completion: @escaping (Result<BackendAdpaterType.AddCardCompletedType,
                                                                   BackendAdpaterType.BackendAdapterErrorType>) -> Void) {

        phService.tokenizeTransaction(transactionId: transactionId,
                                      cardData: card,
                                      encryptionKey: encryptionKey) { [weak self] (resultApiResult) in
            guard let strongSelf = self else { return }

            switch resultApiResult {
            case .success:
                strongSelf.backendAdapter.addCardCompleted(transactionId: transactionId, completion: completion)
            case .failure(let tokenizeTransactionError):
                let resultError = strongSelf.backendAdapter.mapError(error: tokenizeTransactionError)
                completion(.failure(resultError))
            }

        }
    }    
}
