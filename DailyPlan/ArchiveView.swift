//
//  ArchiveView.swift
//  DailyPlan
//
//  Created by Antonio Gambone on 15/12/24.
//


import SwiftUI
import SwiftData

struct ArchiveView: View {
    @Binding var isPresented: Bool
    @Query(sort: \Item.category) private var items: [Item]
    @Environment(\.modelContext) private var modelContext
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationView {
            VStack {
                let archivedItems = items.filter { $0.isArchived }

                if archivedItems.isEmpty {
                    Text("Archive is empty for now.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    let categories = Set(archivedItems.map { $0.category })

                    List {
                        ForEach(categories.sorted(), id: \.self) { category in
                            Section(header: Text(category)) {
                                let filteredItems = archivedItems.filter { $0.category == category }
                                
                                ForEach(filteredItems) { item in
                                    HStack {
                                        Circle()
                                            .fill(priorityColor(for: item.priority))
                                            .frame(width: 12, height: 12)
                                        Text(item.title)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text(item.startDate, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                    .swipeActions(edge: .leading) {
                                        Button {
                                            restoreItem(item)
                                        } label: {
                                            Label("Restore", systemImage: "arrow.uturn.left.circle.fill")
                                        }
                                        .tint(.blue)
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            deleteItem(item)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Archive")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !items.filter({ $0.isArchived }).isEmpty {
                        Button(action: {
                            showingDeleteConfirmation = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
            .confirmationDialog(
                "Delete All Archived Tasks",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete All", role: .destructive) {
                    deleteAllArchivedItems()
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    private func priorityColor(for priority: Priority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .red
        }
    }

    private func restoreItem(_ item: Item) {
        
        withAnimation {
            item.isArchived = false
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            do {
                try modelContext.save()
                print("✅ Successfully restored item: \(item.title)")
                
                
                if item.startDate > Date() {
                    NotificationManager.shared.scheduleNotification(for: item)
                }
            } catch {
                print("❌ Error restoring item: \(error)")
                // Revert the change on error
                withAnimation {
                    item.isArchived = true
                }
                try? modelContext.save()
            }
        }
    }

    private func deleteItem(_ item: Item) {
        withAnimation {
            modelContext.delete(item)
            do {
                try modelContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    private func deleteAllArchivedItems() {
        let archivedItems = items.filter { $0.isArchived }
        for item in archivedItems {
            modelContext.delete(item)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}

#Preview {
    ArchiveView(isPresented: .constant(true))
}
