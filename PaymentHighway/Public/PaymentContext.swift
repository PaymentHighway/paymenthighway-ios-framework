//
//  PH.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 26/06/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

public class PaymentContext<BackendAdpaterType: BackendAdapter> {
    
    let backendAdapter: BackendAdpaterType
    let phService: PaymentHighwayService
    
    public init(config: PaymentConfig, backendAdapter: BackendAdpaterType) {
        self.backendAdapter = backendAdapter
        self.phService = PaymentHighwayService(merchantId: config.merchantId, accountId: config.accountId)
    }

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
            print("apiResult \(apiResult.result.code)")
            backendAdapter.cardAdded(transactionId: transactionId, completion: completion)
        case .failure(let tokenizeTransactionError):
            let resultError = backendAdapter.systemError(error: tokenizeTransactionError)
            completion(.failure(resultError))
        }
    }

}
