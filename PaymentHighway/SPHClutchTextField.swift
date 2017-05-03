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
    case empty = 0
    /// The field was validated and has a valid value
    case valid = 1
    /// The field was validated and has an invalid value
    case invalid = 2
}

open class SPHClutchTextField: UITextField {
	/// The inset to apply to inside the text field's content
	open var inset: Inset = Inset(5, 5)
    
    /// State Handling
    open var fieldState: SPHClutchTextFieldState = .empty {
        didSet {
            if fieldState == SPHClutchTextFieldState.invalid  {
               self.layer.borderColor = UIColor.red.cgColor
            } else {
                self.layer.borderColor = UIColor(hexInt: 0xa6b9dc).cgColor
            }
        }
    }
    
	// MARK: Initializers
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
        
	}
	
	// MARK: Layout
	
	override open func textRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.insetBy(dx: inset.x, dy: inset.y)
	}
	
	open override func editingRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.insetBy(dx: inset.x, dy: inset.y)
	}
}


// MARK: Custom Fields

open class SPHClutchCreditCardTextField: SPHClutchTextField {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
