//
//  ToDoListViewModel.swift
//  TaskListAssignment
//
//  Created by Aidan Hughes on 3/16/25.
//

import Foundation
import SwiftUI
import Combine
import UserNotifications

class ToDoListViewModel: ObservableObject {

    private let repository: ToDoListRepository = ToDoListRepositoryImpl()

    @Published var editingItemId: UUID?
    @Published var inputTask: String = ""
    @Published var taskPriority: String = "Low"
    @Published var taskTime: Date = Date()
    @Published var taskTag: String = "Work"
    @Published var toDoItems: [ToDoItem]  = [ToDoItem(title: "test", priority: "High", time: Date(), tag: "Work")]
    @Published var toggleCompletedText: String = "Hide Completed"
    @Published var showCompleted: Bool = true
    @Published var query: String = ""


    let priorities = ["Low", "Medium", "High"]
    let tags = ["Work", "School", "Personal"]

    var filteredItems: [ToDoItem] {
        if query.isEmpty {
            return toDoItems
        } else {
            return toDoItems.filter { $0.title.localizedCaseInsensitiveContains(query) }
        }
    }


    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
    }

    func setNotification(_ task: String, _ taskTime: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Task Manager"
        content.body = "\(task) is due!"
        content.sound = UNNotificationSound.default

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: taskTime)
        let minute = calendar.component(.minute, from: taskTime)

        var dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if error != nil {
                print("Error: couldn't make notification request")
            } else {
                print("Notification scheduled for \(taskTime)")
            }
        }
    }

    func sortList() {
        let incompleteItems = toDoItems.filter {!$0.isComplete}.sorted {priorities.firstIndex(of: $0.priority)! > priorities.firstIndex(of: $1.priority)!}
        let completeItems = toDoItems.filter {$0.isComplete}.sorted {priorities.firstIndex(of: $0.priority)! > priorities.firstIndex(of: $1.priority)!}

        toDoItems = incompleteItems + completeItems
    }

    func addItem () {
        if inputTask.isEmpty { return }
        toDoItems.append(ToDoItem(title: inputTask, priority: taskPriority, time: taskTime, tag: taskTag))
        setNotification(inputTask, taskTime)
        inputTask = ""
        sortList()
        repository.saveToDoItems(toDoItems)
    }

    func removeItem(_ item: ToDoItem ) {
        if let index = toDoItems.firstIndex(where: {$0.id == item.id}) {
            toDoItems.remove(at: index)
            sortList()
            repository.saveToDoItems(toDoItems)
        }
    }

    func toggleItem(_ item: ToDoItem ) {
        if let index = toDoItems.firstIndex(where: {$0.id == item.id}) {
            toDoItems[index].isComplete.toggle()
            sortList()
            repository.saveToDoItems(toDoItems)
        }
    }

    func toggleCompletedItemVisibility() {
        showCompleted.toggle()
        toggleCompletedText = showCompleted ? "Hide Completed" : "Show Completed"
        sortList()
    }

    func updateItemText(_ item: ToDoItem, _ newValue: String) {
        if let index = toDoItems.firstIndex(where: {$0.id == item.id}) {
            toDoItems[index].title = newValue
            sortList()
            repository.saveToDoItems(toDoItems)
        }
    }

    func onSubmit() {
        editingItemId = nil
        sortList()
        repository.saveToDoItems(toDoItems)
    }

    func onTapItem(_ item: ToDoItem) {
        editingItemId = item.id
        repository.saveToDoItems(toDoItems)
    }

    func loadData()
    {
        toDoItems = repository.loadToDoItems()
        sortList()
    }
}

extension ToDoListViewModel {

}
