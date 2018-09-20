//
//  ExpiryDateSpec.swift
//  PaymentHighwayTests
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Quick
import Nimble
@testable import PaymentHighway

let expiryDateFormatTest = [
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

let expiryDateValidTest = [
    "" : false,
    "11/" : false,
    "/23" : false,
    "10/13" : false, // expiration date in the past
    "13/29" : false,
    "12/29" : true
]

let expiryDateInitTest = [
    "1/1" : ("01", "2001"),
    "13/20" : nil,
    "12/20" : ("12", "2020"),
    "12/2012" : ("12", "2012")
]

class ExpiryDateSpec: QuickSpec {

    override func spec() {
        
        describe("Expiration date formatting") {
            it("should format dates as expected") {
                for (given, (expected, deleting)) in expiryDateFormatTest {
                    let actual = ExpiryDate.format(expiryDate: given, deleting: deleting)
                    expect(actual).to(equal(expected))
                }
            }
        }

        describe("Expiration date isValid") {
            it("should expiration dates valid as expected") {
                for (expiryDate, expectedValid) in expiryDateValidTest {
                    let isValid = ExpiryDate.isValid(expiryDate: expiryDate)
                    expect(isValid).to(equal(expectedValid))
                }
            }
        }

        describe("Expiration date init") {
            it("should expiration dates initialized as expected") {
                for (expiryDate, expected) in expiryDateInitTest {
                    let result = ExpiryDate(expiryDate: expiryDate)
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
