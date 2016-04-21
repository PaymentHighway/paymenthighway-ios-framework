//
//  SPHClutch.swift
//  Clutch
//
//  Created by Nico Hämäläinen on 30/03/15.
//  Copyright (c) 2015 Solinor Oy. All rights reserved.
//

import Foundation
import UIKit
import CryptoSwift

// MARK: Card Types

public struct ClutchDomains {
    static let Default = "fi.solinor.clutch.errordomain"
}

/// The recognized card types in the system
public enum SPHClutchCardType: Int, CustomStringConvertible {
	case Visa = 0
	case MasterCard
	case AmericanExpress
	case Discover
	case JCB
	case DinersClub
	case Unsupported
	case Invalid
	
	/// The valid card types
	static func validValues() -> [SPHClutchCardType] {
		return [.Visa, .MasterCard, .AmericanExpress, .Discover, .JCB, .DinersClub]
	}
	
	/// The invalid card types
	static func invalidValues() -> [SPHClutchCardType] {
		return [.Unsupported, .Invalid]
	}

	/// Returns the correct NSPredicate for validating a card type
	static func matcherPredicateForType(cardType: SPHClutchCardType) -> NSPredicate {
		var regexp: String? = nil
		switch cardType {
		case .Visa:
			regexp = "^4[0-9]{6,}$"
		case .MasterCard:
			regexp = "^5[1-5][0-9]{5,}$"
		case .AmericanExpress:
			regexp = "^3[47][0-9]{5,}$"
		case .Discover:
			regexp = "^6(?:011|5[0-9]{2})[0-9]{3,}$"
		case .JCB:
			regexp = "^(?:2131|1800|35[0-9]{3})[0-9]{3,}$"
		case .DinersClub:
			regexp = "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"
		default:
			regexp = nil
		}
		
		if let regexp = regexp {
			return NSPredicate(format: "SELF MATCHES %@", regexp)
		}
		else {
			return NSPredicate(value: false)
		}
	}
	
	/// Printable
	public var description: String {
		switch self {
		case .Visa: return "Visa"
		case .MasterCard: return "MasterCard"
		case .AmericanExpress: return "AmericanExpress"
		case .Discover: return "Discover"
		case .JCB: return "JCB"
		case .DinersClub: return "DinersClub"
		case .Invalid: return "Invalid"
		case .Unsupported: return "Unsupported"
		}
	}
}

// MARK: Main Class

/// Main Clutch Class
public class SPHClutch {
    
	/// The singleton accessor
	public class var sharedInstance: SPHClutch {
        struct Static {
            static let instance: SPHClutch = SPHClutch()
        }
        
        return Static.instance
	}
    
    private var lastExpirationDateLength = 0
    
    public var networking: Networking?
	
	// MARK: Initializers
	
	public init() { /* Nothing to do here */ }
	
    public class func initSharedInstance(merchantId: String, accountId: String, mobileApiAddress: String) -> SPHClutch {
        SPHClutch.sharedInstance.networking = Networking(merchant: merchantId, accountId: accountId, host: mobileApiAddress)
        return SPHClutch.sharedInstance
	}

	// MARK: Card Recognition and Validation
	
	/// Formats a card number for processing purposes
    ///
	/// - parameter   cardNumber: The card number to format
	/// - returns: The formatted card number, or an empty string
	public func formattedCardNumberForProcessing(cardNumber: String) -> String {
		let illegal    = NSCharacterSet.decimalDigitCharacterSet().invertedSet
		let components = cardNumber.componentsSeparatedByCharactersInSet(illegal)
		return components.joinWithSeparator("")
	}
	
	/// Recognize the type of a credit card number
    ///
	/// - parameter cardNumber: The card number string
	public func cardTypeForCardNumber(cardNumber: String) -> SPHClutchCardType {
		let valid = self.isValidCardNumber(cardNumber)
		if !valid {
			return .Invalid
		}
		
		let formattedString: String = self.formattedCardNumberForProcessing(cardNumber)
		if formattedString.characters.count < 9 {
			return .Invalid
		}
		
		var foundType: SPHClutchCardType = .Invalid
		for type in SPHClutchCardType.validValues() {
			let predicate = SPHClutchCardType.matcherPredicateForType(type)
			if predicate.evaluateWithObject(cardNumber) == true {
				foundType = type
				break
			}
		}
		
		return foundType
	}
	
	/// Validate a given credit card number using the Luhn algorithm
    ///
	/// - parameter   cardNumber: The card number to validate
	/// - returns: true if the number passes, false if not
	public func isValidCardNumber(cardNumber: String) -> Bool {
		let formattedString = self.formattedCardNumberForProcessing(cardNumber)
		if formattedString.characters.count < 9 {
			return false
		}
        
		let asciiOffset: UInt8 = 48
		let digits = Array(Array(formattedString.utf8).reverse()).map{$0 - asciiOffset}
		
		let convert: (UInt8) -> (UInt8) = {
			let n = $0 * 2
			return n > 9 ? n - 9 : n
		}
		
		var sum: UInt8 = 0
		for (index, digit) in digits.enumerate() {
			if index & 1 == 1 {
				sum += convert(digit)
			} else {
				sum += digit
			}
		}
		
		return sum % 10 == 0
	}
	
	/// Format a given card number to a neat string
    ///
	/// - parameter   cardNumber: The card number to format
	/// - parameter   cardType:   The type of the card number
	/// - returns: The properly spaced credit card number
	public func formattedCardNumber(cardNumber: String, cardType: SPHClutchCardType) -> String {
        let formattedString = self.formattedCardNumberForProcessing(cardNumber).truncate(19, trailing: "")
        
		// Stupid AMEX uses their own weird format
		var regexpString = "(\\d{1,4})"
		if cardType == .AmericanExpress {
			regexpString = "(\\d{1,4})(\\d{1,6})?(\\d{1,5})?"
		}
		
		// Create and check regexp matches
		let regexp  = try! NSRegularExpression(pattern: regexpString, options: [])
		var groups  = [String]()
        
        let matches = formattedString.matchesForRegex(regexpString)
		
		// Glue them together
		return matches.joinWithSeparator(" ")
	}
    
    // MARK: expiration date 
    
    public func isValidExpirationDate(expirationDate: String) -> Bool {
        
        if(expirationDate.characters.count == 5)
        {
            let month = expirationDate.componentsSeparatedByString("/")[0]
            let year = "20" + expirationDate.componentsSeparatedByString("/")[1]
         
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMyyyy"
            
            let currentDate = dateFormatter.stringFromDate(NSDate())
                        
            if let givenDate = dateFormatter.dateFromString(month + year) {
                if givenDate.compare(dateFormatter.dateFromString(currentDate)! ) != NSComparisonResult.OrderedAscending { //TODO: there might more easier way to do this..
                    return true
                }
            }
        }
        
        return false
    }
    
    public func formattedExpirationDateForProcessing(expirationDate: String) -> String {
        return formattedCardNumberForProcessing(expirationDate)
    }
    
    public func formattedExpirationDate(expirationDate: String) -> String {
        var onlyDigitsExpirationDate = formattedExpirationDateForProcessing(expirationDate)
        let length = onlyDigitsExpirationDate.characters.count
        
        var text = ""
        
        switch length {
        case 1:
            if(2...9 ~= Int(onlyDigitsExpirationDate)!)
            {
                text = "0\(onlyDigitsExpirationDate)/"
            } else {
                text = onlyDigitsExpirationDate
            }
        case 2:
            if (lastExpirationDateLength == 3)
            {
                text = onlyDigitsExpirationDate
            } else {
                if Int(onlyDigitsExpirationDate)! < 1 || Int(onlyDigitsExpirationDate)! > 12
                {
                    onlyDigitsExpirationDate.removeAtIndex(onlyDigitsExpirationDate.endIndex.predecessor())
                    text = onlyDigitsExpirationDate
                } else {
                    text = "\(onlyDigitsExpirationDate)/"
                }
            }
        case 3:
            onlyDigitsExpirationDate.insert("/", atIndex: onlyDigitsExpirationDate.startIndex.advancedBy(2))
            text = onlyDigitsExpirationDate
        case 4:
            onlyDigitsExpirationDate.insert("/", atIndex: onlyDigitsExpirationDate.startIndex.advancedBy(2))
            text = onlyDigitsExpirationDate
        case 5:
            onlyDigitsExpirationDate.removeAtIndex(onlyDigitsExpirationDate.endIndex.predecessor())
            onlyDigitsExpirationDate.insert("/", atIndex: onlyDigitsExpirationDate.startIndex.advancedBy(2))
            text = onlyDigitsExpirationDate
        default:
            text = ""
        }
        
        lastExpirationDateLength = text.characters.count
        
        return text
    }
    
    public func isValidSecurityCode(securityCode: String) -> Bool {
        return self.formattedSecurityCodeForProcessing(securityCode).characters.count > 0
    }
    
    public func formattedSecurityCodeForProcessing(securityCode: String) -> String {
        return formattedCardNumberForProcessing(securityCode)
    }
    
    public func formattedSecurityCode(securityCode: String) -> String {
        var onlyDigitsSecurityCode = formattedSecurityCodeForProcessing(securityCode)
        var text = ""
        switch onlyDigitsSecurityCode.characters.count
        {
            case 0...4 : text = onlyDigitsSecurityCode
            case 5 :
                onlyDigitsSecurityCode.removeAtIndex(onlyDigitsSecurityCode.endIndex.predecessor())
                text = onlyDigitsSecurityCode
            default : text = ""
        }
        return text
    }
    
    public func addCard(transactionId: String, pan: String, cvc: String, expiryMonth: String, expiryYear: String, success: (String) -> (), failure: (NSError) -> ()) -> () {
        
        func handleReceivedTokenisationResult(result: String) -> () {
            success(result)
        }
        
        func handleFailure(error: NSError) -> () {
            failure(error)
        }
        
        func handleReceivedKeySuccess(key: String) -> () {
            networking!.tokenize(transactionId, expiryMonth: expiryMonth, expiryYear: expiryYear, cvc: cvc, pan: pan, certificateBase64Der: key, success: {success($0)}, failure: {failure($0)})
        }
        
        networking!.getKey(transactionId, success: handleReceivedKeySuccess, failure: handleFailure)
        
        }
    }

