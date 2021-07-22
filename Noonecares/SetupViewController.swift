//
//  SetupViewController.swift
//  Noonecares
//
//  Created by Lesterrry on 22.07.2021.
//

import Cocoa

class SetupViewController: NSViewController {

    @IBOutlet weak var customCommandTextField: NSTextField!
    @IBAction func customCommandSendButtonPressed(_ sender: Any) {
        if MenuViewController.connectionState == .connected {
            MenuViewController.sendCommand(customCommandTextField.stringValue)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
