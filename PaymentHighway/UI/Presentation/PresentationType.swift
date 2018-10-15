//
//  PresentationScale.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

// Define how the view will be presented
public enum PresentationType {

    /// Present the view using the actual view height
    case fullView
    
    /// Present the view in full screen
    case fullScreen

    /// Present the view in half screen
    case halfScreen

    /// Present the view using a custom height
    case custom(CGFloat)

    public var isFullView: Bool {
        if case .fullView = self { return true }
        return false
    }

    public var isFullScreen: Bool {
        if case .fullScreen = self { return true }
        return false
    }

    public var isHalfScreen: Bool {
        if case .halfScreen = self { return true }
        return false
    }

    public var isCustom: Bool {
        if case .custom = self { return true }
        return false
    }

}
