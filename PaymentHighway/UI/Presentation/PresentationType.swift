//
//  PresentationScale.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

public enum PresentationType {
    case fullScreen
    case halfScreen
    case custom(CGFloat)
    
    public var isFullScreen: Bool {
        if case .fullScreen = self {
            return true
        }
        return false
    }

    public var isHalfScreen: Bool {
        if case .halfScreen = self {
            return true
        }
        return false
    }

    public var isCustom: Bool {
        if case .custom = self {
            return true
        }
        return false
    }

}
