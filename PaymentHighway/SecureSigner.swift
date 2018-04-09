//
//  SecureSigner.swift
//  PaymentHighway
//
//  Created by Nico Hämäläinen on 06/03/2017.
//  Copyright © 2017 Payment Highway Oy. All rights reserved.
//

import Foundation
import CryptoSwift

public class SecureSigner {
    let signatureScheme = "SPH1"
    let signatureKeyId: String
    let signatureSecret: String
    
    public init(signatureKeyId: String, signatureSecret: String) {
        self.signatureKeyId = signatureKeyId
        self.signatureSecret = signatureSecret
    }
    
    public func createSignature(method: String, uri: String, keyValues: [(String, String)], body: String) -> String {
        return "\(self.signatureScheme) \(self.signatureKeyId) \(self.sign(method: method, uri: uri, keyValues: keyValues, body: body))"
    }
    
    public func sign(method: String, uri: String, keyValues: [(String, String)], body: String) -> String {
        let stringToSign = "\(method)\n\(uri)\n\(createKeyValueString(keyValues: keyValues))\n\(body.trimmingCharacters(in: .whitespacesAndNewlines))"
        let hmac = try! HMAC(key: signatureSecret, variant: HMAC.Variant.sha256).authenticate(Array(stringToSign.utf8))
        return Data(bytes: hmac).toHexString()
    }
    
    public func createKeyValueString(keyValues: [(String, String)]) -> String {
        return keyValues
            .filter { $0.0.lowercased().hasPrefix("sph-") }
            .sorted { $0.0 < $1.0 }
            .map { "\($0.0.lowercased()):\($0.1)" }
            .joined(separator: "\n")
    }
}
