//
//  BackendAdapter.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

/// Backend Adapter.
///
/// This interface defines what customer has to implement (in own backend) in order to use Payment Highway API
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
    /// Fetch Payment Highway transaction ID via the merchant’s own backend.
    /// The merchant backend gets the ID from Payment Highway using the Init Transaction call.
    ///
    /// - note: Endpoint helper can be used for the REST api implementation
    func getTransactionId(completion: @escaping (Result<TransactionId, BackendAdapterErrorType>) -> Void)

    /// Add card completed
    ///
    /// Callback function, which is called once the add card operation has been completed by the user.
    /// Here one implements the call to the merchant’s backend,
    /// which then fetches the actual tokenization result,
    /// the card token and its details from Payment Highway using the provided
    /// transaction/tokenization ID ( https://dev.paymenthighway.io/#tokenization ) and stores them
    /// Typically the response from the merchant’s backend consists of the card details
    /// to display to the user and an identifier for the card, e.g. the card token,
    /// or some merchant’s internal ID for this payment method.
    ///
    /// - note: Endpoint helper can be used for the REST api implementation
    func addCardCompleted(transactionId: TransactionId, completion: @escaping (Result<AddCardCompletedType, BackendAdapterErrorType>) -> Void)
}
