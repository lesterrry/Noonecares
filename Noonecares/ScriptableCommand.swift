//
//  ScriptableCommand.swift
//  Noonecares
//
//  Created by Lesterrry on 17.02.2022.
//

import Foundation
import Cocoa

class ScriptableApplicationCommand: NSScriptCommand {
    override func performDefaultImplementation() -> Any? {
        let text = self.evaluatedArguments!["commandFlag"] as! String
        if MenuViewController.connectionState == .connected {
            (AppDelegate.popover.contentViewController as! MenuViewController).stopAllAction()
            MenuViewController.systemCurrentMode = .off
            // TODO: It would be cool to adapt interface but ugh i'm lazy
            MenuViewController.sendCommand(text)  // FIXME: I should refrain from using static properties from now on
            return text
        } else {
            return "Fail"
        }
    }
}
