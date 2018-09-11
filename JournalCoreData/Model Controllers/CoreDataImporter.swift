//
//  CoreDataImporter.swift
//  JournalCoreData
//
//  Created by Andrew R Madsen on 9/10/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataImporter {
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
//    func sync(entries: [EntryRepresentation], completion: @escaping (Error?) -> Void = { _ in }) {
//        self.context.perform {
//            for entryRep in entries {
//                guard let identifier = entryRep.identifier else { continue }
//
//                let entry = self.fetchSingleEntryFromPersistentStore(with: identifier, in: self.context)
//                if let entry = entry, entry != entryRep {
//                    self.update(entry: entry, with: entryRep)
//                } else if entry == nil {
//                    _ = Entry(entryRepresentation: entryRep, context: self.context)
//                }
//            }
//            completion(nil)
//        }
//    }
    
    func sync(entries: [EntryRepresentation], completion: @escaping (Error?) -> Void = { _ in }) {
        print("Started syncing...")
        let localEntries = self.fetchAllEntriesFromPersistentStore(in: self.context)
        
        self.context.perform {
            for entryRep in entries {
                guard let identifier = entryRep.identifier else { continue }
                
               let entry = localEntries[identifier]
                
                if let entry = entry, entry != entryRep {
                    self.update(entry: entry, with: entryRep)
                } else if entry == nil {
                    _ = Entry(entryRepresentation: entryRep, context: self.context)
                }
            }
            print("Sync complete.")
            completion(nil)
        }
    }
    
    private func update(entry: Entry, with entryRep: EntryRepresentation) {
        entry.title = entryRep.title
        entry.bodyText = entryRep.bodyText
        entry.mood = entryRep.mood
        entry.timestamp = entryRep.timestamp
        entry.identifier = entryRep.identifier
    }
    
    private func fetchSingleEntryFromPersistentStore(with identifier: String?, in context: NSManagedObjectContext) -> Entry? {
        
        guard let identifier = identifier else { return nil }
        
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        
        var result: Entry? = nil
        do {
            result = try context.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching single entry: \(error)")
        }
        return result
    }
    
    private func fetchAllEntriesFromPersistentStore(in context: NSManagedObjectContext) -> [String : Entry] {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        
        var result: [String : Entry] = [:]
        do {
            let fetchedEntries = try context.fetch(fetchRequest)
            for entry in fetchedEntries {
                result[entry.identifier!] = entry
            }
        } catch {
            NSLog("Error fetching all entries: \(error)")
        }
        return result
    }
    
    let context: NSManagedObjectContext
}
