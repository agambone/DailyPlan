//
//  ContentView.swift
//  DailyPlan
//
//  Created by Antonio Gambone on 11/12/24.


import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.category) private var items: [Item]

    @State private var isAddingNewItem = false
    @State private var isViewingArchive = false
    @State private var isAnimating = false
    @State private var selectedItem: Item?

    var body: some View {
        NavigationView {
            VStack {
                if items.isEmpty {
                   
                    VStack {
                        Spacer()
                        Spacer()
                        
                        // Grouped VStack for accessibility
                        VStack {
                            Text("Create your task!")
                                .font(.largeTitle)
                                .foregroundColor(.black.opacity(0.6))
                                .padding(.bottom, 60)
                                .accessibilityHidden(true)

                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 150))
                                .foregroundColor(.black.opacity(0.7))
                                .rotationEffect(.degrees(isAnimating ? 45 : 0))
                                .scaleEffect(isAnimating ? 1.5 : 1)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                        }
                        .frame(maxWidth: .infinity)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Tap to create your task")
                        .accessibilityAddTraits(.isButton)
                        .onTapGesture {
                            isAddingNewItem = true
                        }
                        .onAppear {
                            isAnimating = true
                        }
                        .onDisappear {
                            isAnimating = false
                        }

                        Spacer()
                        Spacer()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .navigationBarHidden(true)
                } else {
                    let categories = Set(items.map { $0.category })
                    
                    List {
                        
                        if items.filter({ !$0.isArchived }).isEmpty {
                            VStack(spacing: 20) {
                                Text("No tasks planned")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top, 70)
                            }
                            .listRowBackground(Color.clear)
                        } else {
                            ForEach(categories.sorted(), id: \.self) { category in
                                let filteredItems = items.filter { $0.category == category && !$0.isArchived }

                                if !filteredItems.isEmpty {
                                    Section(header: Text(category).accessibilityAddTraits(.isHeader)) {
                                        ForEach(filteredItems) { item in
                                            HStack {
                                                Circle()
                                                    .fill(priorityColor(for: item.priority))
                                                    .frame(width: 12, height: 12)
                                                    .accessibilityHidden(true)
                                                Text(item.title)
                                                Spacer()
                                                Text(item.startDate, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                                                    .font(.footnote)
                                                    .foregroundColor(.secondary)
                                            }
                                            .accessibilityElement(children: .combine)
                                            .accessibilityLabel("\(item.title), scheduled for \(item.startDate.formatted(date: .abbreviated, time: .shortened)), \(item.priority.rawValue) priority")
                                            .swipeActions(edge: .leading) {
                                                Button {
                                                    do {
                                                        NotificationManager.shared.cancelNotification(for: item)
                                                        withAnimation {
                                                            item.isArchived = true
                                                        }
                                                        try modelContext.save()
                                                    } catch {
                                                        print("Error archiving item: \(error)")
                                                    }
                                                } label: {
                                                    Label("Archive", systemImage: "archivebox.fill")
                                                }
                                                .tint(.blue)
                                                .accessibilityLabel("Archive task")
                                            }
                                            .swipeActions(edge: .trailing) {
                                                Button {
                                                    do {
                                                        NotificationManager.shared.cancelNotification(for: item)
                                                        selectedItem = item
                                                        isAddingNewItem = true
                                                    } catch {
                                                        print("Error preparing item for edit: \(error)")
                                                    }
                                                } label: {
                                                    Label("Edit", systemImage: "pencil")
                                                }
                                                .tint(.yellow)
                                                .accessibilityLabel("Edit task")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .accessibilityLabel("Tasks list")
                }
            }
            // Fixed: Show title for any non-empty list view
            .navigationTitle(!items.isEmpty ? "Your Tasks" : "")
            .toolbar {
                if !items.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            isViewingArchive = true
                        }) {
                            Image(systemName: "archivebox")
                                .accessibilityLabel("View archived tasks")
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            selectedItem = nil
                            isAddingNewItem = true
                        }) {
                            Image(systemName: "plus")
                                .accessibilityLabel("Add your task")
                        }
                    }
                }
            }
            .sheet(isPresented: $isAddingNewItem) {
                AddItemView(isPresented: $isAddingNewItem, itemToEdit: selectedItem)
                    .onDisappear {
                        if let item = selectedItem {
                            do {
                                NotificationManager.shared.scheduleNotification(for: item)
                                try modelContext.save()
                            } catch {
                                print("Error scheduling notification: \(error)")
                            }
                        }
                        selectedItem = nil
                    }
            }
            .sheet(isPresented: $isViewingArchive) {
                ArchiveView(isPresented: $isViewingArchive)
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
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
