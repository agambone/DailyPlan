//
//  AddItemView.swift
//  DailyPlan
//
//  Created by Antonio Gambone on 12/12/24.
//


import SwiftUI
import SwiftData

struct AddItemView: View {
   
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    let itemToEdit: Item?

    @State private var title = ""
    @State private var category = "General"
    @State private var customCategory = ""
    @State private var startDate = Date()
    @State private var startTime = Date()
    @State private var priority: Priority = .low

  
    @FocusState private var focusedField: FocusField?

    private enum FocusField: Hashable {
        case title
        case customCategory
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details").accessibilityHidden(true)) {
                    
                    ZStack(alignment: .leading) {
                        if title.isEmpty {
                            Text("Title")
                                .foregroundColor(.gray)
                                .accessibilityHidden(true)
                        }
                        TextField("", text: $title)
                            .focused($focusedField, equals: .title)
                            .accessibilityHidden(true)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Task title")

                    
                    VStack {
                        Picker("Category", selection: $category) {
                            Text("General").tag("General")
                            Text("Home").tag("Home")
                            Text("Academy").tag("Academy")
                            Text("Work").tag("Work")
                            Text("University").tag("University")
                            Text("Other").tag("Other")
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: category) { newValue in
                            if newValue == "Other" {
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    focusedField = .customCategory
                                }
                            }
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Category")

                    if category == "Other" {
                        
                        ZStack(alignment: .leading) {
                            if customCategory.isEmpty {
                                Text("Custom category")
                                    .foregroundColor(.gray)
                                    .accessibilityHidden(true)
                            }
                            TextField("", text: $customCategory)
                                .focused($focusedField, equals: .customCategory)
                                .accessibilityHidden(true)
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Custom category name")
                    }

                    
                    VStack {
                        DatePicker("Date", selection: $startDate, displayedComponents: [.date])
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Press to select the date")

                    
                    VStack {
                        DatePicker("Time", selection: $startTime, displayedComponents: [.hourAndMinute])
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Press to select the time")
                }

                
                Section {
                    ForEach([Priority.low, .medium, .high], id: \.self) { priorityOption in
                        HStack {
                            Circle()
                                .fill(priorityOption.color)
                                .frame(width: 12, height: 12)
                                .accessibilityHidden(true)
                            Text(priorityOption.rawValue.capitalized)
                                .accessibilityHidden(true)
                            Spacer()
                            if priority == priorityOption {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                                    .accessibilityHidden(true)
                            }
                        }
                        .contentShape(Rectangle())
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(priorityOption.rawValue)
                        .accessibilityAddTraits(priority == priorityOption ? [.isButton, .isSelected] : .isButton)
                        .onTapGesture {
                            priority = priorityOption
                        }
                    }
                } header: {
                    Text("Priority")
                        .accessibilityLabel("Select priority")
                        .accessibilityAddTraits([])
                }
            }
            .navigationTitle(itemToEdit == nil ? "New Task" : "Edit Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        resetForm()
                        isPresented = false
                    }
                    .accessibilityLabel("Cancel")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                        resetForm()
                        isPresented = false
                    }
                    .disabled(title.isEmpty || (category == "Other" && customCategory.isEmpty))
                    .accessibilityLabel("Save task")
                    .accessibilityHint(title.isEmpty ? "Enter title to save" : "")
                }
            }
            .onAppear {
                if let item = itemToEdit {
                    title = item.title
                    category = item.category
                    customCategory = item.category == "Other" ? item.category : ""
                    startDate = item.startDate
                    startTime = item.startDate
                    priority = item.priority
                } else {
                    resetForm()
                }
                
                focusedField = .title
            }
        }
    }

    
    private func resetForm() {
        title = ""
        category = "General"
        customCategory = ""
        startDate = Date()
        startTime = Date()
        priority = .low
    }

    private func saveItem() {
        guard !title.isEmpty else { return }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: startDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let combinedDate = calendar.date(
            bySettingHour: timeComponents.hour ?? 0,
            minute: timeComponents.minute ?? 0,
            second: 0,
            of: calendar.date(from: components)!
        )!

        let finalCategory = category == "Other" ? customCategory : category

        if let item = itemToEdit {
            NotificationManager.shared.cancelNotification(for: item)
            item.title = title
            item.category = finalCategory
            item.startDate = combinedDate
            item.priority = priority
            NotificationManager.shared.scheduleNotification(for: item)
        } else {
            let newItem = Item(title: title, startDate: combinedDate, category: finalCategory, priority: priority)
            modelContext.insert(newItem)
            NotificationManager.shared.scheduleNotification(for: newItem)
        }

        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}


#Preview {
    AddItemView(isPresented: .constant(true), itemToEdit: nil)
        .modelContainer(for: Item.self, inMemory: true)
}


