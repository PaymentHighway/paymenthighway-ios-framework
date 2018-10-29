//
//  BaseViewController.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import UIKit

/// Base class for all the SDK UIViewControllers
public class BaseViewController: UIViewController {
    
    var okButton: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    
    var themeDidSet: (() -> Void)?
    private var okButtonLabel: String

    var theme: Theme {
        didSet {
            themeDidSet?()
        }
    }
    
    public init(theme: Theme = DefaultTheme.instance, nibName: String, okButtonLabel: String) {
        self.theme = theme
        self.okButtonLabel = okButtonLabel
        super.init(nibName: nibName, bundle: Bundle(for: type(of: self)))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(BaseViewController.cancelPressed(_:)))
        cancelButton.setTitleTextAttributes([.foregroundColor: theme.highlightColor], for: .normal)
        cancelButton.setTitleTextAttributes([.foregroundColor: theme.highlightDisableColor], for: .disabled)
        navigationItem.leftBarButtonItem = cancelButton
        
        handleOkButton()
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = theme.barTintColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: theme.primaryForegroundColor, .font: theme.emphasisFont]
    }

    /// Show toast depending of the thme on top of bottoom of the view
    public func showToast(message: String, completion: (() -> Void)? = nil) {
        Toast.show(view: view, theme: theme, message: message, completion: completion)
    }

    @objc func cancelPressed(_ sender: Any) {
         fatalError("cancelPressed has not been implemented")
    }
    
    @objc func okPressed(_ sender: Any) {
        fatalError("okPressed has not been implemented")
    }
    
    func enableUserInput(enabled: Bool, okButtonEnabled: Bool) {
        handleOkButton(spinner: !enabled, okButtonEnabled: okButtonEnabled)
        cancelButton.isEnabled = enabled
    }
    
    private func handleOkButton(spinner: Bool = false, okButtonEnabled: Bool = false) {
        navigationItem.rightBarButtonItem = nil
        if spinner == false {
            okButton = UIBarButtonItem(title: okButtonLabel,
                                       style: .plain,
                                       target: self,
                                       action: #selector(BaseViewController.okPressed(_:)))
            okButton.isEnabled = okButtonEnabled
            okButton.setTitleTextAttributes([.foregroundColor: theme.highlightColor], for: .normal)
            okButton.setTitleTextAttributes([.foregroundColor: theme.highlightDisableColor], for: .disabled)
            
        } else {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: theme.barTintColor.isLight() ? .gray : .white)
            activityIndicator.hidesWhenStopped = false
            activityIndicator.startAnimating()
            okButton = UIBarButtonItem(customView: activityIndicator)
        }
        navigationItem.rightBarButtonItem = okButton
    }
}
