//
//  BackendAdapterTest.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 06/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import PaymentHighway

struct TransactionToken: Decodable {
    let token: String
}

class BackendAdapterTest: BackendAdapter {

    func getTransactionId(completion: @escaping (Result<TransactionId, BackendAdapterTestError>) -> Void) {
        BackendAdapterTestEndpoint.transactionId.getJson { (result: Result<TransactionId, NetworkError>) in
            switch result {
            case .success(let transactionId):
                completion(.success(transactionId))
            case .failure(let networkError):
                completion(.failure(BackendAdapterTestError.networkError(networkError)))
            }
        }
    }
    
    func cardAdded(transactionId: TransactionId, completion: @escaping (Result<TransactionToken, BackendAdapterTestError>) -> Void) {
        BackendAdapterTestEndpoint.transactionToken(transactionId: transactionId).post { (result: Result<TransactionToken, NetworkError>) in
            switch result {
            case .success(let transactionToken):
                completion(.success(transactionToken))
            case .failure(let networkError):
                completion(.failure(BackendAdapterTestError.networkError(networkError)))
            }
        }
    }
    
    func systemError(error: Error) -> BackendAdapterTestError {
        return .systemError(error)
    }
    
}
