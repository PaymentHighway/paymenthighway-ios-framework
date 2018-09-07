//
//  BackendAdapter.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

/// Backend Adapter.
///
/// This interface define what customer have to implement (in own backend) in order to use Payment Highway API
//
public protocol BackendAdapter {
    
    /// Associated type for the card add completed return data
    associatedtype AddCardCompletedType

    /// Associated type for the backend adpater error
    associatedtype BackendAdapterErrorType : Error
    
    /// Map a domain/system error in a backend adapter error
    func mapError(error: Error) -> BackendAdapterErrorType
    
    /// Get the transaction id
    ///
    /// Customer need to implement REST API to get from own backend a transaction id
    /// - note: Endpoint helper can be used for the REST api implementation
    func getTransactionId(completion: @escaping (Result<TransactionId, BackendAdapterErrorType>) -> Void)

    /// Add card completed
    ///
    /// Customer need to implement REST API to notify to own backend that operation to add card is completed.
    /// Backend might return data in order to perform a payment like a transaction token
    /// - note: Endpoint helper can be used for the REST api implementation
    func addCardCompleted(transactionId: TransactionId, completion: @escaping (Result<AddCardCompletedType, BackendAdapterErrorType>) -> Void)
}
