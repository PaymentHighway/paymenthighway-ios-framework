//
//  AddCardViewController.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 28/06/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

public class AddCardViewController: UIViewController {
    
    public init(completion: (Result<CardData, CardAddError>) -> Void) {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
