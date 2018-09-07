//
//  BackendAdapterExample.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 06/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import PaymentHighway

struct TransactionToken: Decodable {
    let token: String
}

class BackendAdapterExample: BackendAdapter {

    func getTransactionId(completion: @escaping (Result<TransactionId, BackendAdapterExampleError>) -> Void) {
        BackendAdapterExampleEndpoint.transactionId.getJson { (result: Result<TransactionId, NetworkError>) in
            switch result {
            case .success(let transactionId):
                completion(.success(transactionId))
            case .failure(let networkError):
                completion(.failure(BackendAdapterExampleError.networkError(networkError)))
            }
        }
    }
    
    func addCardCompleted(transactionId: TransactionId, completion: @escaping (Result<TransactionToken, BackendAdapterExampleError>) -> Void) {
        BackendAdapterExampleEndpoint.transactionToken(transactionId: transactionId).postJson { (result: Result<TransactionToken, NetworkError>) in
            switch result {
            case .success(let transactionToken):
                completion(.success(transactionToken))
            case .failure(let networkError):
                completion(.failure(BackendAdapterExampleError.networkError(networkError)))
            }
        }
    }
    
    func mapError(error: Error) -> BackendAdapterExampleError {
        return .systemError(error)
    }
    
}
