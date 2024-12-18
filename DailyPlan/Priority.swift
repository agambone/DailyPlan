//
//  Priority.swift
//  DailyPlan
//
//  Created by Antonio Gambone on 17/12/24.
//

import Foundation
import SwiftUI

enum Priority: String, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var color: Color {
        switch self {
        case .low:
            return .green
        case .medium:
            return .yellow
        case .high:
            return .red
        }
    }
}
