//
//  CoreDataStack.swift
//  Lydia Technical Test
//
//  Created by Billy Cauchy-Tharin on 04/06/2023.
//

import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: PersistentContainer = {
        let container = PersistentContainer(name: "Model")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent store: \(error)")
            }
        }
        return container
    }()
    
}
