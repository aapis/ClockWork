//
//  CoreDataNotes.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

public class CoreDataNotes {
    public var moc: NSManagedObjectContext?
    
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }
    
    public func forDate(_ date: Date) -> [Note] {
        var results: [Note] = []
        
        let (before, after) = DateHelper.startAndEndOf(date)
        
        let fetch: NSFetchRequest<Note> = Note.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Note.postedDate, ascending: false)]
        fetch.predicate = NSPredicate(
            format: "(postedDate > %@ && postedDate <= %@) || (lastUpdate > %@ && lastUpdate <= %@) && alive = true",
            before as CVarArg,
            after as CVarArg,
            before as CVarArg,
            after as CVarArg
        )

        do {
            results = try moc!.fetch(fetch)
        } catch {
            print("Unable to find records for today")
        }
        
        return results
    }
}