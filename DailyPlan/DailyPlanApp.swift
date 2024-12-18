//
//  DailyPlanApp.swift
//  DailyPlan
//
//  Created by Antonio Gambone on 11/12/24.
//

import SwiftUI
import SwiftData

@main
struct DailyPlanApp: App {
    
    init() {
        NotificationManager.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Item.self)
        }
    }
}
