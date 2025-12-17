//
//  ValidationState.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 17/12/25.
//

import Foundation

/// Represents the validation state of a form field, including a potential error message.
enum ValidationState: Equatable {
    case valid
    case invalid(message: String)
    case empty
    
    var isInvalid: Bool {
        if case .invalid = self {
            return true
        }
        return false
    }
    
    var message: String? {
        if case .invalid(let message) = self {
            return message
        }
        return nil
    }
}
