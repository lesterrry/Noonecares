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
}
