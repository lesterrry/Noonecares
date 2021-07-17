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
