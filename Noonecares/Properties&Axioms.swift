//
//  Properties & Axioms.swift
//  Noonecares
//
//  Created by Aydar Nasibullin on 20.07.2021.
//

import Cocoa

/// Collection of different system attributes
class SystemProperties {
    
    /// The way matrix behaves
    enum Mode: Int {
        case text
        case keyTrace
        case CCPS
        case timer
        case pomodoro
        case clock
        case nowPlaying
        case off
    }
    
    /// State of user-selected options and parameters
    enum ApplianceState {
        case applied
        case notApplied
        case corruptedParameters
    }
    
    /// State of serial connection
    enum ConnectionState {
        case connected
        case disconnected
    }

}

/// Collections of system methods
class SystemMethods {
    
    /// Safely print debug info to console
    /// - Parameter text: String to print
    public static func log(_ text: Any) {
        #if DEBUG
        print(text)
        #endif
    }
    
    /// Get first existing value from a tuple of two
    /// - Parameter from: Tuple to extract a value from
    /// - Returns: First existing value if any, nil if none
    public static func firstExisting(_ from:(Any?, Any?)) -> Any? {
        if let a = from.0 {
            return a
        } else if let b = from.1 {
            return b
        }
        return nil
    }
    
}
