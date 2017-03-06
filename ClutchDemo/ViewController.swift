//
//  ViewController.swift
//  ClutchDemo
//
//  Created by Nico Hämäläinen on 01/04/15.
//  Copyright (c) 2015 Solinor Oy. All rights reserved.
//

import UIKit
import Clutch

class ViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

    @IBOutlet weak var logForUser: UITextView!
  
    @IBAction func addCard(_ sender: UIButton) {
        
        let hostname = "http://54.194.196.206:8081" // development
        
        logForUser.text = "Add card-button pushed.\n\(logForUser.text)"
                
        SPHClutch.sharedInstance.transactionId(
            hostname: hostname,
            success: {
                let txId = $0
                self.presentSPHAddCardViewController(
                    self,
                    animated: true,
                    transactionId : txId,
                    success: {
                        self.logForUser.text = "\($0)\n\(self.logForUser.text)"
                        SPHClutch.sharedInstance.transactionToken(
                            hostname: hostname,
                            transactionId: txId,
                            success: {self.logForUser.text = "\($0)\n\(self.logForUser.text)"},
                            failure: {self.logForUser.text = "\($0)\n\(self.logForUser.text)"})
                    },
                    error: {self.logForUser.text = "\($0)\n\(self.logForUser.text)"},
                    completion: {self.logForUser.text = "User completed the form.\n\(self.logForUser.text)"})
            },
            failure: {self.logForUser.text = "\($0)\n\(self.logForUser.text)"})
    }
}

