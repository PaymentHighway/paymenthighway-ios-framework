//
//  PH.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

/// `PaymentContext` manage all the functionality around a payment like addCard.
///
public class PaymentContext<BackendAdpaterType: BackendAdapter> {
    
    let backendAdapter: BackendAdpaterType
    let phService: PaymentHighwayService
    
    /// This is required to initialize `PaymentContext`
    ///
    /// - parameter config: The configuration of the `PaymentContext`
    /// - parameter backendAdapter: Provide your BackendAdpater implementation
    /// - seealso: PaymentConfig
    /// - seealso: BackendAdapter
    /// - seealso: Result
    ///
    public init(config: PaymentConfig, backendAdapter: BackendAdpaterType) {
        self.backendAdapter = backendAdapter
        self.phService = PaymentHighwayService(merchantId: config.merchantId, accountId: config.accountId)
    }

    /// This add a new Payment Card.
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
                self?.getTransactionIdHandler(transactionId: transactionId, card: card, completion: completion)
            case .failure(let transactionIdError):
                completion(.failure(transactionIdError))
            }
        }
    }
    
    private func getTransactionIdHandler(transactionId: TransactionId,
                                         card: CardData,
                                         completion: @escaping (Result<BackendAdpaterType.AddCardCompletedType,
                                                                       BackendAdpaterType.BackendAdapterErrorType>) -> Void) {
        phService.transactionKey(transactionId: transactionId) { [weak self] (resultTransactionKey) in
            guard let strongSelf = self else { return }
            switch resultTransactionKey {
            case .success(let transactionKey):
                strongSelf.transactionKeyHandler(transactionKey: transactionKey, transactionId: transactionId, card: card, completion: completion)
            case .failure(let transactionKeyError):
                completion(.failure(strongSelf.backendAdapter.mapError(error: transactionKeyError)))
            }
        }
    }
    
    private func transactionKeyHandler(transactionKey: TransactionKey,
                                       transactionId: TransactionId,
                                       card: CardData,
                                       completion: @escaping (Result<BackendAdpaterType.AddCardCompletedType,
                                                                     BackendAdpaterType.BackendAdapterErrorType>) -> Void) {

        phService.tokenizeTransaction(transactionId: transactionId,
                                      cardData: card,
                                      transactionKey: transactionKey) { [weak self] (resultApiResult) in
            guard let strongSelf = self else { return }

            switch resultApiResult {
            case .success(let apiResult):
                if apiResult.result.code == ApiResult.success {
                    strongSelf.backendAdapter.addCardCompleted(transactionId: transactionId, completion: completion)
                } else {
                    let resultError = strongSelf.backendAdapter.mapError(error: NetworkError.internalError(apiResult.result.code, apiResult.result.message))
                    completion(.failure(resultError))
                }
            case .failure(let tokenizeTransactionError):
                let resultError = strongSelf.backendAdapter.mapError(error: tokenizeTransactionError)
                completion(.failure(resultError))
            }

        }
    }    
}
