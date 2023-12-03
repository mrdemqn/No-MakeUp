//
//  CoreDataSevice.swift
//  Instaura
//
//  Created by Димон on 16.11.23.
//

import CoreData
import UIKit

final class CoreDataService {
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "No-MakeUp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func createObject(closure: @escaping (NSManagedObjectContext) -> Client,
                      completion: @escaping (NSManagedObjectID) -> Void) {
        context.performAndWait {
            let client = closure(context)
            self.saveContext()
            completion(client.objectID)
        }
    }
    
    func saveContext () {
        if context.hasChanges {
            do {
                try self.context.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    func fetch<T: NSManagedObject>(type: T.Type,
                                   predicate: NSPredicate) -> [T] {
        let fetchRequest: NSFetchRequest<T> = T.fetchTypedRequest(type)
        fetchRequest.predicate = predicate
        do {
            let objects = try context.fetch(fetchRequest)
            return objects
        } catch {
            let error = error as NSError
            print("Fetch Error: \(error.userInfo)")
            return []
        }
    }
    
    func fetchWithId(id objectID: NSManagedObjectID) -> Client? {
        do {
            guard let object = try context.existingObject(with: objectID) as? Client else { return nil }
            return object
        } catch {
            let error = error as NSError
            print("Fetch Error: \(error.userInfo)")
            return nil
        }
    }
    
    func fetchWithURL(with url: URL) -> Client? {
        guard let objectID = persistentContainer.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else { return nil }
        return fetchWithId(id: objectID)
    }
    
    func deleteObjects() {
        let entities = persistentContainer.managedObjectModel.entities
        for entity in entities {
            delete(entityName: entity.name!)
        }
    }
    
    func delete(entityName: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
}
