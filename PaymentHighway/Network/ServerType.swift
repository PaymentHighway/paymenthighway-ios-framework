//
//  ServerType.swift
//  PaymentHighway
//
//  Created by Margs Sipria on 01.12.2017.
//  Copyright © 2017 Payment Highway Oy. All rights reserved.
//

import Foundation

/// Interface to provide endpoint base URL
///
public protocol ServerType {
    static var baseURL: String { get }
}
