//
//  Result.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 28/06/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

public enum Result<SuccessType, ErrorType: Error> {
    case success(SuccessType)
    case failure(ErrorType)
    
    public init(value: SuccessType) {
        self = .success(value)
    }
    
    public init(error: ErrorType) {
        self = .failure(error)
    }
}
