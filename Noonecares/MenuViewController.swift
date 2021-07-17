//
//  MenuViewController.swift
//  Noonecares
//
//  Created by Lesterrry on 17.07.2021.
//

import Cocoa

class MenuViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func matrixButtonPressed(_ sender: Any) {
        let myWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "MatrixWindowController") as! NSWindowController
        myWindowController.showWindow(self)
    }
    
    @IBAction func quitButtonPressed(_ sender: Any) {
        exit(0)
    }
}

extension MenuViewController {
  static func freshController() -> MenuViewController {
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    let identifier = NSStoryboard.SceneIdentifier("MenuViewController")
    guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? MenuViewController else {
      fatalError("No controller found")
    }
    return viewController
  }
}
