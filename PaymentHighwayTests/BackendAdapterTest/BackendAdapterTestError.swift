//
//  BackendAdapterTestError.swift
//  PaymentHighwayTests
//
//  Created by Stefano Pironato on 06/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import PaymentHighway

enum BackendAdapterTestError: Error {
    case networkError(NetworkError)
    case systemError(Error)
}
