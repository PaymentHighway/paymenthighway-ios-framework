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
                        completion: @escaping (Result<BackendAdpaterType.CardAddedType, BackendAdpaterType.BackendAdapterErrorType>) -> Void) {
        backendAdapter.getTransactionId { [weak self] (resultTransactionId) in
            self?.getTransactionIdCompletionHandler(result: resultTransactionId, card: card, completion: completion)
        }
    }
    
    private func getTransactionIdCompletionHandler(result: Result<TransactionId, BackendAdpaterType.BackendAdapterErrorType>,
                                                   card: CardData,
                                                   completion: @escaping (Result<BackendAdpaterType.CardAddedType,
                                                                          BackendAdpaterType.BackendAdapterErrorType>) -> Void) {
        switch result {
        case .success(let transactionId):
            phService.transactionKey(transactionId: transactionId) { [weak self] (resultTransactionKey) in
                self?.transactionKeyCompletionHandler(result: resultTransactionKey, transactionId: transactionId, card: card, completion: completion)
            }
        case .failure(let transactionIdError):
            completion(.failure(transactionIdError))
        }
    }
    
    private func transactionKeyCompletionHandler(result: Result<TransactionKey, NetworkError>,
                                                 transactionId: TransactionId,
                                                 card: CardData,
                                                 completion: @escaping (Result<BackendAdpaterType.CardAddedType,
                                                                        BackendAdpaterType.BackendAdapterErrorType>) -> Void) {
        switch result {
        case .success(let transactionKey):
            // call phservice.tokenizeTransaction
            phService.tokenizeTransaction(transactionId: transactionId,
                                          cardData: card,
                                          transactionKey: transactionKey) { [weak self] (apiResult) in
                self?.tokenizeTransactionCompletionHandler(result: apiResult, transactionId: transactionId, completion: completion)
            }
            
        case .failure(let transactionKeyError):
            let resultError = backendAdapter.systemError(error: transactionKeyError)
            completion(.failure(resultError))
        }
    }
    
    private func tokenizeTransactionCompletionHandler(result: Result<ApiResult, NetworkError>,
                                                      transactionId: TransactionId,
                                                      completion: @escaping (Result<BackendAdpaterType.CardAddedType,
                                                                             BackendAdpaterType.BackendAdapterErrorType>) -> Void) {
        switch result {
        case .success(let apiResult):
            if apiResult.result.code == ApiResult.success {
                backendAdapter.cardAdded(transactionId: transactionId, completion: completion)
            } else {
                print("Error in tokenizeTransaction \(apiResult.result.code) \(apiResult.result.message)")
                let resultError = backendAdapter.systemError(error: NetworkError.internalError(apiResult.result.code, apiResult.result.message))
                completion(.failure(resultError))
            }
        case .failure(let tokenizeTransactionError):
            let resultError = backendAdapter.systemError(error: tokenizeTransactionError)
            completion(.failure(resultError))
        }
    }

}
