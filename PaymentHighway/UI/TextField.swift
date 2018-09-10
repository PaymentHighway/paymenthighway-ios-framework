//
//  TextField.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import UIKit

private let defaultAdjustPlaceholderY: CGFloat = 4

private let imageTag = 8899

/// TextField is the base class for the specialized text fields UI elements for collecting credit card information.
///
open class TextField: UITextField, UITextFieldDelegate {

    lazy var paddingX: CGFloat = theme.textPaddingX
    
    var theme: Theme = DefaultTheme.instance {
        didSet {
            initializeTheme()
            setNeedsDisplay()
        }
    }
    
    var isValid: Bool = false {
        didSet {
            validationDelegate?.isValidDidChange(isValid, self)
        }
    }
    
    /// Optional validation delegate
    ///
    /// - seealso: `TextFieldValidationDelegate`
    public weak var validationDelegate: ValidationDelegate?

    /// Text formatter: default implementation no formatting
    ///
    open var format: (String) -> String = { (text) in text }

    /// Text validation: default implementation invalid
    ///
    open var validate: (String) -> Bool = { (_) in return false }

    private var placeholderLabel = UILabel()
    
    private var placeholderHeight : CGFloat {
        return defaultAdjustPlaceholderY + placeholderFont().lineHeight
    }
    
    private func placeholderFont() -> UIFont {
        if isFirstResponder || text!.isNotEmpty {
            return UIFont(name: theme.font.fontName, size: theme.font.pointSize * theme.placeholderFontScale)!
        }
        return theme.font
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initializeTheme() {
        font = theme.font
        backgroundColor = theme.secondaryBackgroundColor
    }
    
    private func initialize() {
        self.delegate = self
        keyboardType = UIKeyboardType.numberPad
        initializeTheme()
        addTarget(self, action: #selector(TextField.formatAndValidateTextField(_:)), for: UIControlEvents.editingChanged)
    }
    
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewsForTextEntry()
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
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
            return CGRect(x: paddingX, y: defaultAdjustPlaceholderY, width: bounds.width, height: placeholderHeight)
        } else {
            return textRect(forBounds: bounds)
        }
    }

    open func animateViewsForTextEntry() {
        UIView.animate(withDuration: theme.placeholderAnimationDuration, animations: {
            self.updateUI()
        })
    }
    
    open func animateViewsForTextDisplay() {
        UIView.animate(withDuration: theme.placeholderAnimationDuration, animations: {
            self.updateUI()
        })
    }
    
    open func drawViewsForRect(_ rect: CGRect) {
        updateTextImage()
        updateUI()
        addSubview(placeholderLabel)
    }
    
    override open func draw(_ rect: CGRect) {
        drawViewsForRect(rect)
    }
    
    override open func drawPlaceholder(in rect: CGRect) {
        // Don't draw any placeholders
    }
    
    open var textFieldType: TextFieldType?
    
    // MARK: Layout
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        if isFirstResponder ||
           (text?.isNotEmpty ?? false) {
            return  bounds.offsetBy(dx: paddingX, dy: placeholderHeight/2)
        }
        return  bounds.offsetBy(dx: paddingX, dy: 0)
    }

    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    private func updateTextImage() {
        guard let textFieldType = textFieldType,
              theme.textImages.contains(textFieldType) else { return }
        
        if let oldImage = self.viewWithTag(imageTag) {
            oldImage.removeFromSuperview()
        }
        if let image = theme.textImageView(textFieldType: textFieldType, height: self.frame.height) {
            paddingX = self.frame.height
            image.tag = imageTag
            addSubview(image)
        } else {
            paddingX = theme.textPaddingX
        }
    }
    
    private func updateUI() {
        updateBorder()
        updatePlaceholder()
        textColor = theme.textColor(isActive: isFirstResponder)
    }
    
    private func updatePlaceholder() {
        placeholderLabel.frame = placeholderRect(forBounds: bounds)
        placeholderLabel.text = placeholder
        placeholderLabel.font = placeholderFont()
        placeholderLabel.textColor = theme.placeholderLabelColor(isActive: isFirstResponder, isValid: checkIfIsValid)
        placeholderLabel.textAlignment = textAlignment
    }
    
    private func setBorderStyle() {
        layer.borderWidth  = theme.borderWidth
        layer.cornerRadius = theme.borderRadius
    }
    
    private func updateBorder() {
        setBorderStyle()
        layer.borderColor = theme.borderColor(isActive: isFirstResponder, isValid: checkIfIsValid).cgColor
    }
    
    private var firstCheckDone: Bool = false
    
    private var checkIfIsValid: Bool? {
        guard let textLength = text?.lengthOfBytes(using: .utf8), textLength > 0 else { return nil }
        if !firstCheckDone && isFirstResponder {
            return nil
        }
        firstCheckDone = true
        return isValid
    }
}
