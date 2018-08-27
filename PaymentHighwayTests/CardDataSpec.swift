//
//  CardDataSpec.swift
//  PaymentHighwayTests
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Quick
import Nimble
@testable import PaymentHighway

// Test Data
let validCardBrands: [CardBrand: [String]] = [
    .americanExpress: ["378282246310005", "371449635398431", "378734493671000"],
    .dinersClub:      ["30569309025904", "38520000023237"],
    .discover:        ["6011111111111117", "6011000990139424"],
    .jcb:             ["3530111333300000", "3566002020360505"],
    .mastercard:      ["5555555555554444", "5105105105105100"],
    .visa:            ["4444333322221111", "4012888888881881", "4222222222222"]
]

let invalidCardBrands = ["378282246310006", "371449635398432", "305693090259043", "371449635398432", "4242424242424240", "9944333322221111"]

let securityCodeFormats = [
    "" : "",
    "0" : "0",
    "00" : "00",
    "000" : "000",
    "0000" : "0000",
    "00000" : "0000",
    "41234" : "4123",
    "123412344234" : "",
    " 1 43 / 2k k nkm" : "1432"
]

// swiftlint:disable function_body_length
class CardDataSpec: QuickSpec {
    
    override func spec() {
        
        // move this in string extension test?
        describe("Card Formatting for processing") {
            it("should remove illegal characters") {
                let actualCardNumber = "55555🐺5555a5554 44,. -4".decimalDigits
                expect(actualCardNumber).to(equal("5555555555554444"))
            }
            it("should do nothing if already formatted") {
                let actualCardNumber = "378282246310005".decimalDigits
                expect(actualCardNumber).to(equal("378282246310005"))
            }
        }
        
        // MARK: Card Recognition
        
        describe("Card Recognition") {
            it("should recognize basic card types from their numbers") {
                for (cardBrand, cardNumbers) in validCardBrands {
                    for cardNumber in cardNumbers {
                        // Should recognise brand with just a first part of the card number (5 for jcb)22
                        if let foundCardBrand = CardBrand.from(cardNumber: String(cardNumber.prefix(5))) {
                            expect(foundCardBrand).to(equal(cardBrand))
                        } else {
                            fail("Card brand \(cardBrand) not found")
                        }
                    }
                }
            }
            
            it("shouldn't recognize invalid card numbers as any type") {
                for cardNumber in invalidCardBrands {
                    expect(CardData.isValid(cardNumber: cardNumber)).to(beFalse())
                }
            }
        }
        
        // MARK: Credit Card Validation
        
        describe("Card Validation") {
            it("should cards be valid") {
                for (_, cardNumbers) in validCardBrands {
                    for cardNumber in cardNumbers {
                        let isValid = CardData.isValid(cardNumber: cardNumber)
                        expect(isValid).to(beTrue())
                    }
                }
            }
            
            it("should cards be invalid") {
                for cardNumber in invalidCardBrands {
                    let isValid = CardData.isValid(cardNumber: cardNumber)
                    expect(isValid).to(beFalse())
                }
            }

        }
        
        describe("Card Formatting") {
            it("should format VISA") {
                let actualCardNumber = CardData.format(cardNumber: "5555555555554444")
                expect(actualCardNumber).to(equal("5555 5555 5555 4444"))
            }
            it("should format AMEX") {
                let actualCardNumber = CardData.format(cardNumber: "378282246310005")
                expect(actualCardNumber).to(equal("3782 822463 10005"))
            }
            it("should format DINNER") {
                let actualCardNumber = CardData.format(cardNumber: "30569309025904")
                expect(actualCardNumber).to(equal("3056 930902 5904"))
            }
            
        }
        
        // MARK: Security code formatting
        
        describe("Security code formatting") {
            it("Format security code as expected") {
                for (given, expected) in securityCodeFormats {
                    let actual = CardData.format(securityCode: given)
                    expect(actual).to(equal(expected))
                }
            }
        }
    }
}
