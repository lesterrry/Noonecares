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
        print(text)
        return text
    }
}
