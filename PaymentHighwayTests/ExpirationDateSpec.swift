//
//  ExpirationDateSpec.swift
//  PaymentHighwayTests
//
//  Created by Stefano Pironato on 29/06/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Quick
import Nimble
@testable import PaymentHighway

let expirationDateFormatTest = [
    "" : ("", false),
    "0" : ("0", false),
    "00" : ("0", false),
    "1" : ("1", false),
    "11" : ("11/", false),
    "12" : ("1", true), // deleting case
    "11/" : ("11/", false),
    "12/" : ("12/", true), // deleting case
    "13" : ("1", false),
    "23" : ("2", false),
    "10/1" : ("10/1", false),
    "10/" : ("10/", false),
    "8" : ("08/", false),
    "10/13" : ("10/13", false),
    "10/134" : ("10/13", false),
    "10/1334" : ("", false),
    "aas/df1" : ("1", false)
]

let expirationDateValidTest = [
    "" : false,
    "11/" : false,
    "/23" : false,
    "10/13" : false, // expiration date in the past
    "13/29" : false,
    "12/29" : true
]

let expirationDateInitTest = [
    "1/1" : ("01", "2001"),
    "13/20" : nil,
    "12/20" : ("12", "2020"),
    "12/2012" : ("12", "2012")
]

class ExpirationDateSpec: QuickSpec {

    override func spec() {
        
        describe("Expiration date formatting") {
            it("should format dates as expected") {
                for (given, (expected, deleting)) in expirationDateFormatTest {
                    let actual = ExpirationDate.format(expirationDate: given, deleting: deleting)
                    expect(actual).to(equal(expected))
                }
            }
        }

        describe("Expiration date isValid") {
            it("should expiration dates valid as expected") {
                for (expirationDate, expectedValid) in expirationDateValidTest {
                    let isValid = ExpirationDate.isValid(expirationDate: expirationDate)
                    expect(isValid).to(equal(expectedValid))
                }
            }
        }

        describe("Expiration date init") {
            it("should expiration dates initialized as expected") {
                for (expirationDate, expected) in expirationDateInitTest {
                    let result = ExpirationDate(expirationDate: expirationDate)
                    if result == nil {
                        expect(expected).to(beNil())
                    } else {
                        expect(result!.month).to(equal(expected!.0))
                        expect(result!.year).to(equal(expected!.1))
                    }
                }
            }
        }

    }
}
