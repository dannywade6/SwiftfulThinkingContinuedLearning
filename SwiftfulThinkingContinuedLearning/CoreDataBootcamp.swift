//
//  CoreDataBootcamp.swift
//  SwiftfulThinkingContinuedLearning
//
//  Created by Danny Wade on 10/04/2023.
//

import SwiftUI
import CoreData

// View - UI
// Model - Data Point
// ViewModel - Manages the data for a view

class CoreDataViewModel: ObservableObject {
    
    let container: NSPersistentContainer
    @Published var savedEntities: [FruitEntity] = []
    
    init() {
        container = NSPersistentContainer(name: "FruitsContainer")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading CoreData \(error.localizedDescription)")
            }
        }
        fetchFruit()
        
    }
    
    func fetchFruit() {
        let request = NSFetchRequest<FruitEntity>(entityName: "FruitEntity")
        
        do {
            savedEntities = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching. \(error.localizedDescription)")
        }
        
    }
    
    func addFruit(text: String) {
        let newFruit = FruitEntity(context: container.viewContext)
        newFruit.name = text
        saveData()
    }
    
    func deleteFruit(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let entity = savedEntities[index]
        container.viewContext.delete(entity)
        saveData()
    }
    
    func updateFruit(entity: FruitEntity) {
        let currentName = entity.name ?? ""
        let newName = currentName + "!"
        entity.name = newName
        saveData()
        
    }
    
    func saveData() {
        do {
            try container.viewContext.save()
            fetchFruit()
        } catch let error {
            print("Error saving. \(error.localizedDescription)")
        }
    }
}

struct CoreDataBootcamp: View {
    
    @StateObject var vm = CoreDataViewModel()
    @State var textfieldText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Add fruit here...", text: $textfieldText)
                    .font(.headline)
                    .padding(.leading)
                    .frame(height: 55)
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                Button {
                    guard !textfieldText.isEmpty else { return }
                    vm.addFruit(text: textfieldText)
                    textfieldText = ""
                } label: {
                    Text("Submit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.pink.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                List {
                    ForEach(vm.savedEntities) { entity in
                        Text(entity.name ?? "No Name")
                            .onTapGesture {
                                vm.updateFruit(entity: entity)
                            }
                    }
                    .onDelete(perform: vm.deleteFruit)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Fruits")
        }
    }
}

struct CoreDataBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        CoreDataBootcamp()
    }
}
