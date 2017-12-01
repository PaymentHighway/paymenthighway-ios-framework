//
//  SecureSignerSpec.swift
//  PaymentHighway
//
//  Created by Nico Hämäläinen on 06/03/2017.
//  Copyright © 2017 Payment Highway Oy. All rights reserved.
//

import Foundation
import Quick
import Nimble
import PaymentHighway

class SecureSignerSpec: QuickSpec {
    override func spec() {
        beforeSuite {
            SPH.initSharedInstance(
                merchantId: SPHMerchantID,
                accountId: SPHAccountID,
                signatureKeyId: SPHSignatureKeyId,
                signatureSecret: SPHSignatureSecret,
                mobileApiAddress: SPHServiceURL
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
                let signer = SecureSigner(signatureKeyId: SPHSignatureKeyId, signatureSecret: SPHSignatureSecret)
                let signature = signer.createSignature(method: "POST", uri: "/form/view/payment", keyValues: [
                    ("sph-api-version", "20151028")
                ], body: "")
                expect(signature.contains(SPHSignatureKeyId)).to(equal(true))
            }
        }
    }
}
