//
//  TaskListView.swift
//  DailyPlan
//
//  Created by Antonio Gambone on 15/12/24.
//

import SwiftUI
import SwiftData

struct TaskListView: View {
   let category: String
   let items: [Item]
   let onDelete: (Item) -> Void

   var body: some View {
       List {
           ForEach(items) { item in
               HStack {
                   Text(item.title)
                   Spacer()
                   Text(item.startDate, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                       .font(.footnote)
                       .foregroundColor(.secondary)
               }
               .swipeActions {
                   Button(role: .destructive) {
                       onDelete(item)
                   } label: {
                       Label("Delete", systemImage: "trash")
                   }
               }
           }
       }
   }
}

#Preview {
   TaskListView(
       category: "Home",
       items: [
           Item(title: "Example Task 1", startDate: Date(), category: "Home"),
           Item(title: "Example Task 2", startDate: Date(), category: "Home")
       ],
       onDelete: { _ in }
   )
   .modelContainer(for: Item.self, inMemory: true)
}
