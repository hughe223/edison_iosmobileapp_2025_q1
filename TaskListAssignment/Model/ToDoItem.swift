//
//  ToDoItem.swift
//  TaskListAssignment
//
//  Created by Aidan Hughes on 3/16/25.
//

import Foundation

struct ToDoItem: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var isComplete: Bool = false
    var priority: String
    var time: Date
    var tag: String
}
