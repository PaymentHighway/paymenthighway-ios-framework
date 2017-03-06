//
//  SecureSignerSpec.swift
//  Clutch
//
//  Created by Nico Hämäläinen on 06/03/2017.
//  Copyright © 2017 Solinor Oy. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Clutch

class SecureSignerSpec: QuickSpec {
    override func spec() {
        beforeSuite {
            SPHClutch.initSharedInstance(
                merchantId: SPHClutchMerchantID,
                accountId: SPHClutchAccountID,
                signatureKeyId: SPHClutchSignatureKeyId,
                signatureSecret: SPHClutchSignatureSecret,
                mobileApiAddress: SPHClutchServiceURL
            )
        }
        
        describe("Sign") {
            it("Key value pairs") {
                let signer = SecureSigner(signatureKeyId: "testKey", signatureSecret: "testSecret")
                expect(signer.createKeyValueString(keyValues: [
                    ("hello", "world"),
                    ("sph-demo", "sph-value")
                ])).to(equal("sph-demo:sph-value"))
                
                expect(signer.createKeyValueString(keyValues: [
                    ("hello", "world"),
                    ("sph-1", "sph-value1"),
                    ("sph-2", "sph-value2"),
                    ("sph-3", "sph-value3")
                ])).to(equal("sph-1:sph-value1\nsph-2:sph-value2\nsph-3:sph-value3"))
            }
            
            it("Creates signatures properly") {
                let signer = SecureSigner(signatureKeyId: SPHClutchSignatureKeyId, signatureSecret: SPHClutchSignatureSecret)
                let signature = signer.createSignature(method: "POST", uri: "/form/view/payment", keyValues: [
                    ("sph-api-version", "20151028")
                ], body: "")
                expect(signature.contains(SPHClutchSignatureKeyId)).to(equal(true))
            }
        }
    }
}
