//
//  TextField.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 16/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import UIKit

private let defaultAdjustPlaceholderY: CGFloat = 4

private let imageTag = 8899

open class TextField: UITextField {

    lazy var adjustX: CGFloat = theme.textAdjustX
    
    var theme: Theme = DefaultTheme.instance {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var isValid: Bool = false {
        didSet {
            validationDelegate?.isValidDidChange(isValid, self)
        }
    }
    
    weak var validationDelegate: TextFieldValidationDelegate?

    open var format: (String) -> String = { (text) in text }

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
    
    private func initialize() {
        keyboardType = UIKeyboardType.numberPad
        font = theme.font
        backgroundColor = theme.secondaryBackgroundColor
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
            return CGRect(x: adjustX, y: defaultAdjustPlaceholderY, width: bounds.width, height: placeholderHeight)
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
            return  bounds.offsetBy(dx: adjustX, dy: placeholderHeight/2)
        }
        return  bounds.offsetBy(dx: adjustX, dy: 0)
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
            adjustX = self.frame.height
            image.tag = imageTag
            addSubview(image)
        } else {
            adjustX = theme.textAdjustX
        }
    }
    
    private func updateUI() {
        updateBorder()
        updatePlaceholder()
        textColor = theme.textColor(isValid: isValid, isActive: isFirstResponder)
    }
    
    private func updatePlaceholder() {
        placeholderLabel.frame = placeholderRect(forBounds: bounds)
        placeholderLabel.text = placeholder
        placeholderLabel.font = placeholderFont()
        placeholderLabel.textColor = theme.placeholderLabelColor(isValid: isValid, isActive: isFirstResponder)
        placeholderLabel.textAlignment = textAlignment
    }
    
    private func setBorderStyle() {
        layer.borderWidth  = theme.borderWidth
        layer.cornerRadius = theme.borderRadius
    }
    
    private func updateBorder() {
        setBorderStyle()
        layer.borderColor = theme.borderColor(isValid: isValid, isActive: isFirstResponder).cgColor
    }
    
}
