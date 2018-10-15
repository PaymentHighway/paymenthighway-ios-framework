//
//  SettingsViewController.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import UIKit
import PaymentHighway

protocol HandlerSetting {
    func isSelected(index: Int) -> Bool
    mutating func select(index: Int)
}

enum ThemeItem: Int {
    case `default`
    case dark
}

extension ThemeItem: TableRowItem {
    var title: String {
        switch self {
        case .default: return "Default theme"
        case .dark: return "Dark theme"
        }
    }
    
    static var count: Int {
        return 2
    }
}

enum PresenterItem: Int, TableRowItem {
    case fullScreen
    case popupScreen
    
    var title: String {
        switch self {
        case .fullScreen: return "Full screen"
        case .popupScreen: return "Popup view"
        }
    }
    
    static var count: Int {
        return 2
    }
}

enum SettingsSection: Int, TableSectionItem {
    case presenter
    case theme
    
    var title: String {
        switch self {
        case .presenter: return "Presenter type"
        case .theme: return "Theme"
        }
    }
    
    static var count: Int {
        return 2
    }
    
    var rows: [TableRowItem] {
        switch self {
        case .presenter: return [PresenterItem.fullScreen, PresenterItem.popupScreen]
        case .theme: return [ThemeItem.default, ThemeItem.dark]
        }
    }
}

protocol SettingsDelegate: class {
    func presentationTypeDidChange(presentationType: PresentationType)
    func themeDidChange(themeItem: ThemeItem)
}

class SettingsViewController: UITableViewController {
    
    struct PresenterHandler : HandlerSetting {
        
        var presenterType: PresentationType
        weak var delegate: SettingsDelegate?
        
        func isSelected(index: Int) -> Bool {
            if let item = PresenterItem(rawValue: index) {
                switch item {
                case .fullScreen: return self.presenterType.isFullScreen
                case .popupScreen: return self.presenterType.isFullView
                }
            }
            return false
        }
        
        mutating func select(index: Int) {
            if let item = PresenterItem(rawValue: index) {
                switch item {
                case .fullScreen: presenterType = .fullScreen
                case .popupScreen: presenterType = .fullView
                }
                delegate?.presentationTypeDidChange(presentationType: presenterType)
            }
        }
    }

    struct ThemeHandler : HandlerSetting {
        
        var themeItem: ThemeItem
        weak var delegate: SettingsDelegate?
        
        func isSelected(index: Int) -> Bool {
            if let item = ThemeItem(rawValue: index) {
                return item == themeItem
            }
            return false
        }
        
        mutating func select(index: Int) {
            if let item = ThemeItem(rawValue: index) {
                themeItem = item
                delegate?.themeDidChange(themeItem: themeItem)
            }
        }
    }

    weak var delegate: SettingsDelegate? {
        didSet {
            themeHandler.delegate = delegate
            presenterHandler.delegate = delegate
        }
    }
    
    private var presenterHandler: PresenterHandler
    private var themeHandler: ThemeHandler

    // Handler for each section
    lazy var handlers: [SettingsSection: HandlerSetting] = [.presenter:presenterHandler, .theme:themeHandler]
    
    init(presenterType: PresentationType, themeItem: ThemeItem, delegate: SettingsDelegate? = nil) {
        self.presenterHandler = PresenterHandler(presenterType: presenterType, delegate: delegate)
        self.themeHandler = ThemeHandler(themeItem: themeItem, delegate: delegate)
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
    }
    
    // MARK: UITableViewDelegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sectionItem = SettingsSection(rawValue: section) {
            return sectionItem.rows.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sectionItem = SettingsSection(rawValue: section) {
            return sectionItem.title
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        if let sectionItem = SettingsSection(rawValue: indexPath.section),
           sectionItem.rows.count > indexPath.row,
           let handler = handlers[sectionItem] {
            let row = sectionItem.rows[indexPath.row]
            cell.selectionStyle = .none
            cell.textLabel?.text = row.title
            cell.accessoryType = handler.isSelected(index: indexPath.row) ? .checkmark : .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let sectionItem = SettingsSection(rawValue: indexPath.section),
           handlers[sectionItem] != nil {
            handlers[sectionItem]!.select(index: indexPath.row)
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
        }
    }

    @objc func done() {
        dismiss(animated: true, completion: nil)
    }

}
