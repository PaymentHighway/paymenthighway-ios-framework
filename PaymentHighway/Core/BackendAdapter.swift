//
//  BackendAdapter.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 28/06/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

public protocol BackendAdapter {
    associatedtype CardAddedType
    associatedtype BackendAdapterErrorType : Error
    func systemError(error: Error) -> BackendAdapterErrorType
    func getTransactionId(completion: @escaping (Result<TransactionId, BackendAdapterErrorType>) -> Void)
    func cardAdded(transactionId: TransactionId, completion: @escaping (Result<CardAddedType, BackendAdapterErrorType>) -> Void)
}
