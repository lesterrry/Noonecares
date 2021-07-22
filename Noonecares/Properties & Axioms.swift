//
//  Properties & Axioms.swift
//  Noonecares
//
//  Created by Aydar Nasibullin on 20.07.2021.
//

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
    
}
