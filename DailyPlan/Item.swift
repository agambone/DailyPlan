//
//  Item.swift
//  DailyPlan
//
//  Created by Antonio Gambone on 11/12/24.
//

import Foundation
import SwiftData

@Model
final class Item: Identifiable {
    
    var id: UUID
    @Attribute var title: String
    @Attribute var startDate: Date
    @Attribute var category: String
    @Attribute var isArchived: Bool = false
    @Attribute var priority: Priority

    init(title: String, startDate: Date, category: String, priority: Priority = .medium) {
        self.id = UUID()
        self.title = title
        self.startDate = startDate
        self.category = category
        self.priority = priority
    }
}

