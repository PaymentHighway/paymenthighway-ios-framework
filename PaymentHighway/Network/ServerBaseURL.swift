//
//  ServerType.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

/// Interface to provide endpoint base URL
///
public protocol ServerBaseURL {
    var baseURL: URL { get }
}
