//
//  ContentView.swift
//  TaskListAssignment

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = ToDoListViewModel()
    
    var body: some View {
        VStack {
            VStack{
                HStack{
                    TextField("Input task", text: $viewModel.inputTask)
                    Spacer()
                    DatePicker("", selection: $viewModel.taskTime, displayedComponents: [.hourAndMinute])
                }
                .padding([.leading, .trailing, .bottom], 15)
                
                HStack{
                    Picker("Priority", selection: $viewModel.taskPriority)
                    {
                        ForEach(viewModel.priorities, id: \.self) { priority in
                            Text(priority).tag(priority)
                        }
                    }
                    Spacer()
                    .pickerStyle(MenuPickerStyle())
                    Picker("Tag", selection: $viewModel.taskTag)
                    {
                        ForEach(viewModel.tags, id: \.self) { tag in
                            Text(tag).tag(tag)
                        }
                    }
                    Spacer()
                    Button("Add") {
                        viewModel.addItem()
                    }
                }
                .padding([.leading, .trailing, .bottom], 15)
            }

            .background(Color.blue.opacity(0.2))
            
//            HStack{
//                Text("Task")
//                Spacer().frame(width: 103)
//                Text("Tagl")
//            }
//            .padding(.top, 20)
//            .padding(.leading, 70)
//            .padding(.trailing, 95)
            
//            Divider()
            
            List {
                ForEach(viewModel.filteredItems) { item in
                    if(viewModel.showCompleted || !viewModel.showCompleted && !item.isComplete){
                        HStack {
                            Image(systemName: item.isComplete ? "checkmark.circle.fill" : "circle")
                                .onTapGesture {
                                    viewModel.toggleItem(item)
                                }
                            if viewModel.editingItemId == item.id {
                                TextField("", text: Binding(
                                    get: { item.title },
                                    set: { newValue in
                                        viewModel.updateItemText(item, newValue)
                                    }
                                ))
                                .frame(minWidth: 100, alignment: .leading )
                                .onSubmit {
                                    viewModel.onSubmit()
                                }
                            } else {
                                Text(item.title)
                                    .strikethrough(item.isComplete)
                                    .onTapGesture {
                                        viewModel.onTapItem(item)
                                    }
                            }
                            
                            Spacer()
                            Text("\(item.tag)")
                                .multilineTextAlignment(.leading)
                            Spacer().frame(width: 50)
                            Button {
                                viewModel.removeItem(item)
                            } label: {
                                Image(systemName: "minus.circle")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .background(
                            Group {
                                if item.isComplete {
                                    Color.gray
                                }
                                else if item.priority == "Low" {
                                    Color.green
                                }
                                else if item.priority == "Medium" {
                                    Color.yellow
                                }
                                else if item.priority == "High" {
                                    Color.red
                                }
                            }
                        )
                    }
                }
            }
            .listStyle(PlainListStyle())
            Spacer()
            HStack{
                TextField("Search", text: $viewModel.query)
                Button("\(viewModel.toggleCompletedText)") {
                    viewModel.toggleCompletedItemVisibility()
                }
            }   .padding([.leading, .trailing], 20)
                .background(Color.blue.opacity(0.2))
        }
        .onAppear() {
            viewModel.loadData()
            viewModel.requestNotificationPermission()
        }
    }
}

#Preview {
    ContentView()
}
