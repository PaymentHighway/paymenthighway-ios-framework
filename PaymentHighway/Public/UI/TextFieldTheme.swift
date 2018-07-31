//
//  TextFieldTheme.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 26/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

struct TextFieldTheme {
    
    private let validBorderColor = UIColor(hexInt: 0xa6b9dc)
    private let invalidBorderColor = UIColor(hexInt: 0xe80f0f)
    private let invalidActiveBorderColor = UIColor(hexInt: 0x993333)
    
    static private let defaultPlaceholderInset = Inset(2, 4)
    static private let defaultTextFieldInsets = Inset(2, 0)
    static private let defaulRoundedBorderRadius: CGFloat = 20
    static private let defaultPlaceholderFontScale: CGFloat = 0.7
    static private let defaulBorderWidth: CGFloat = 1.5
    
    var animationDuration = 0.3
    
    var isValid: Bool = false
    var rounded: Bool = false
    
    func getBorderColor(_ active: Bool) -> UIColor {
        if isValid {
            return validBorderColor
        }
        return active ? invalidActiveBorderColor : invalidBorderColor
    }
    
    func getPlaceholderLabelColor(_ active: Bool) -> UIColor {
        if isValid {
            return validBorderColor
        }
        return active ? invalidActiveBorderColor : invalidBorderColor
    }
    
    var borderRadius: CGFloat {
        if rounded {
            return TextFieldTheme.defaulRoundedBorderRadius
        }
        return 0
    }
    
    var borderWidth: CGFloat {
        if rounded {
            return TextFieldTheme.defaulBorderWidth
        }
        return TextFieldTheme.defaulBorderWidth
    }
    
    var placeholderInsets: Inset = defaultPlaceholderInset
    var textFieldInsets: Inset = defaultTextFieldInsets
    var placeholderFontScale: CGFloat = defaultPlaceholderFontScale
    var roundedBorderRadius: CGFloat = defaulRoundedBorderRadius
}   
