//
//  SPHClutchTextField.swift
//  Clutch
//
//  Created by Nico Hämäläinen on 01/04/15.
//  Copyright (c) 2015 Solinor Oy. All rights reserved.
//

import Foundation
import UIKit


/// The possible states for a text field to have
public enum SPHClutchTextFieldState: Int {
    /// Is empty and not validated yet
    case Empty = 0
    /// The field was validated and has a valid value
    case Valid = 1
    /// The field was validated and has an invalid value
    case Invalid = 2
}

public class SPHClutchTextField: UITextField {
	/// The inset to apply to inside the text field's content
	public var inset: Inset = Inset(5, 5)
    
    /// State Handling
    public var fieldState: SPHClutchTextFieldState = .Empty {
        didSet {
            if fieldState == SPHClutchTextFieldState.Invalid  {
               self.layer.borderColor = UIColor.redColor().CGColor
            } else {
                self.layer.borderColor = UIColor(hexInt: 0xa6b9dc).CGColor
            }
        }
    }
    
	// MARK: Initializers
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	public required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
        
	}
	
	// MARK: Layout
	
	override public func textRectForBounds(bounds: CGRect) -> CGRect {
		return CGRectInset(bounds, inset.x, inset.y)
	}
	
	public override func editingRectForBounds(bounds: CGRect) -> CGRect {
		return CGRectInset(bounds, inset.x, inset.y)
	}
}


// MARK: Custom Fields

public class SPHClutchCreditCardTextField: SPHClutchTextField {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}