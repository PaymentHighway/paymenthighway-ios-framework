//
//  ServerType.swift
//  PaymentHighway
//
//  Created by Margs Sipria on 01.12.2017.
//  Copyright © 2017 Payment Highway Oy. All rights reserved.
//

import Foundation

public protocol ServerType {
    static var baseURL: String { get }
}
public struct ProductionServer: ServerType {
    public static var baseURL: String { return "https://v1.api.paymenthighway.io/" }
}
public struct StagingServer: ServerType {
    public static var baseURL: String { return  "https://v1-hub-staging.sph-test-solinor.com/" }
}
