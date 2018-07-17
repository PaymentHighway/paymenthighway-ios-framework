//
//  TextField.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 16/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import UIKit

open class TextField: UITextField {

    private var theme: TextFieldTheme = TextFieldTheme()
    
    var isValid: Bool = false {
        didSet {
            validationDelegate?.isValidDidChange(isValid, self)
            theme.isValid = isValid
        }
    }
    
    weak var validationDelegate: TextFieldValidationDelegate?

    open var format: (String) -> String = { (text) in text }

    open var validate: (String) -> Bool = { (_) in return false }

    private var placeholderLabel = UILabel()
    
    private var placeholderHeight : CGFloat {
        return theme.placeholderInsets.y + placeholderFont().lineHeight
    }
    
    private func placeholderFont() -> UIFont! {
        if isFirstResponder || text!.isNotEmpty, let font = font {
            return UIFont(name: font.fontName, size: font.pointSize * theme.placeholderFontScale)
        }
        return font
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        rounded = true
        keyboardType = UIKeyboardType.numberPad
        addTarget(self, action: #selector(TextField.formatAndValidateTextField(_:)), for: UIControlEvents.editingChanged)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textFieldDidEndEditing),
                                               name: .UITextFieldTextDidEndEditing,
                                               object: self)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textFieldDidBeginEditing),
                                               name: .UITextFieldTextDidBeginEditing,
                                               object: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc open func textFieldDidBeginEditing() {
        animateViewsForTextEntry()
    }
    
    @objc open func textFieldDidEndEditing() {
        animateViewsForTextDisplay()
    }
    
    @objc func formatAndValidateTextField(_ textView: AnyObject) {
        let newText = format(self.text ?? "")
        isValid = validate(newText) 
        self.text = newText
    }
    
    override open var text: String? {
        didSet {
            if let text = text, text.isNotEmpty {
                animateViewsForTextEntry()
            } else {
                animateViewsForTextDisplay()
            }
        }
    }
    
    override open var bounds: CGRect {
        didSet {
            updateBorder()
        }
    }
    
    override open var placeholder: String? {
        didSet {
            updatePlaceholder()
        }
    }
    
    open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        if isFirstResponder || text!.isNotEmpty {
            return CGRect(x: theme.placeholderInsets.x, y: theme.placeholderInsets.y, width: bounds.width, height: placeholderHeight)
        } else {
            return textRect(forBounds: bounds)
        }
    }

    open func animateViewsForTextEntry() {
        UIView.animate(withDuration: theme.animationDuration, animations: {
            self.updateBorder()
            self.updatePlaceholder()
        })
    }
    
    open func animateViewsForTextDisplay() {
        UIView.animate(withDuration: theme.animationDuration, animations: {
            self.updateBorder()
            self.updatePlaceholder()
        })
    }
    
    open func drawViewsForRect(_ rect: CGRect) {
        updateBorder()
        updatePlaceholder()
        addSubview(placeholderLabel)
    }
    
    override open func draw(_ rect: CGRect) {
        drawViewsForRect(rect)
    }
    
    override open func drawPlaceholder(in rect: CGRect) {
        // Don't draw any placeholders
    }
    
    open var rounded: Bool = false {
        didSet {
            theme.rounded = rounded
            setBorderStyle()
        }
    }

    open var textFieldIcon: TextFieldIcon? {
        didSet {
            guard let cardIcon = textFieldIcon else { return }
            theme.placeholderInsets = Inset(self.frame.height+theme.placeholderInsets.x, theme.placeholderInsets.y)
            theme.textFieldInsets = Inset(self.frame.height+theme.textFieldInsets.x, theme.textFieldInsets.y)
            addSubview(cardIcon.getImageView(height: self.frame.height))
        }
    }
    
    // MARK: Layout
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        if isFirstResponder ||
           (text?.isNotEmpty ?? false) {
            return  bounds.offsetBy(dx: theme.textFieldInsets.x, dy: theme.textFieldInsets.y + placeholderHeight/2)
        }
        return  bounds.offsetBy(dx: theme.textFieldInsets.x, dy: theme.textFieldInsets.y)
    }

    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    private func updatePlaceholder() {
        placeholderLabel.frame = placeholderRect(forBounds: bounds)
        placeholderLabel.text = placeholder
        placeholderLabel.font = placeholderFont()
        placeholderLabel.textColor = theme.getPlaceholderLabelColor(isFirstResponder)
        placeholderLabel.textAlignment = textAlignment
    }
    
    private func setBorderStyle() {
        layer.borderWidth  = theme.borderWidth
        layer.cornerRadius = theme.borderRadius
    }
    
    private func updateBorder() {
        setBorderStyle()
        layer.borderColor = theme.getBorderColor(isFirstResponder).cgColor
    }
    
}
