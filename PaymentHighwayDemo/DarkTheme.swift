//
//  DarkTheme.swift
//  PaymentHighwayDemo
//
//  Created by Stefano Pironato on 09/08/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import PaymentHighway

class DarkTheme: DefaultTheme {
    override init() {
        super.init()
        borderRadius = 0
        textImages = []
        primaryBackgroundColor = UIColor(hexInt: 0x31698a)
        secondaryBackgroundColor = UIColor(hexInt: 0x6897bb)
        primaryForegroundColor = UIColor.darkGray
        primaryActiveForegroundColor = UIColor.white
        secondaryForegroundColor = primaryForegroundColor
        secondaryActiveForegroundColor = primaryActiveForegroundColor
        errorForegroundColor = UIColor(hexInt: 0xa0d7ce)
        errorActiveForegroundColor = UIColor(hexInt: 0x90e2bc)
        highlightColor = UIColor(hexInt: 0x3366ff)
        highlightDisableColor = UIColor.darkGray
    }
}
