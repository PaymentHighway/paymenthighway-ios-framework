//
//  BackendAdapter.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 28/06/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

/// Backend Adapter.
///
/// This interface define what customer have to implement (in own backend) in order to use Payment Highway API
//
public protocol BackendAdapter {
    
    /// Associated type for the card add return data
    associatedtype CardAddedType

    /// Associated type for the backend adpater error
    associatedtype BackendAdapterErrorType : Error
    
    /// Convert a domain/system error in a own backend adapter error
    func systemError(error: Error) -> BackendAdapterErrorType

    /// Get the transaction id
    ///
    /// Customer need to implement REST API to get from own backend a transaction id
    /// - note: Endpoint helper can be used for the REST api implementation
    func getTransactionId(completion: @escaping (Result<TransactionId, BackendAdapterErrorType>) -> Void)

    /// Card added
    ///
    /// Customer need to implement REST API to notify to own backend that a card has been added.
    /// Backend might return data in order to perform a payment like a transaction token
    /// - note: Endpoint helper can be used for the REST api implementation
    func cardAdded(transactionId: TransactionId, completion: @escaping (Result<CardAddedType, BackendAdapterErrorType>) -> Void)
}
