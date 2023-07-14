//
//  CoreDataRecords.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

public class CoreDataRecords: ObservableObject {
    public var moc: NSManagedObjectContext?
    
    private let lock = NSLock()

    @AppStorage("general.syncColumns") public var syncColumns: Bool = false
    @AppStorage("today.showColumnIndex") public var showColumnIndex: Bool = true
    @AppStorage("today.showColumnTimestamp") public var showColumnTimestamp: Bool = true
    @AppStorage("today.showColumnJobId") public var showColumnJobId: Bool = true
    
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }
    
    public func createWithJob(job: Job, date: Date, text: String) -> Void {
        let record = LogRecord(context: moc!)
        record.timestamp = date
        record.message = text
        record.id = UUID()
        record.job = job
        
        do {
            try moc!.save()
        } catch {
            PersistenceController.shared.save()
        }
    }
    
    public func createWithJobAndReturn(job: Job, date: Date, text: String) -> LogRecord {
        let record = LogRecord(context: moc!)
        record.timestamp = date
        record.message = text
        record.id = UUID()
        record.job = job
        
        do {
            try moc!.save()
        } catch {
            PersistenceController.shared.save()
        }
        
        return record
    }
    
    public func waitForRecent(_ numWeeks: Double = 6) async -> [LogRecord] {
        return recent(numWeeks)
    }
    
    public func waitForRecent(_ start: CVarArg, _ end: CVarArg) async -> [LogRecord] {
        return recent(start, end)
    }
    
    public func recent(_ numWeeks: Double = 6) -> [LogRecord] {
        let cutoff = DateHelper.daysPast(numWeeks * 7)
        
        let predicate = NSPredicate(
            format: "timestamp > %@",
            cutoff
        )
        
        return query(predicate)
    }
    
    public func recent(_ start: CVarArg, _ end: CVarArg) -> [LogRecord] {
        let predicate = NSPredicate(
            format: "timestamp > %@ && timestamp <= %@",
            start,
            end
        )
        
        return query(predicate)
    }
    
    public func countWordsIn(_ records: [LogRecord]) -> Int {
        var words: [String] = []
        
        for rec in records {
            if rec.message != nil {
                words.append(rec.message!)
            }
        }
        
        let wordSet: Set = Set(words.joined(separator: " ").split(separator: " "))
        
        return wordSet.count
    }
    
    public func countJobsIn(_ records: [LogRecord]) -> Int {
        var jobs: [Double] = []
        
        for rec in records {
            if rec.job != nil {
                jobs.append(rec.job!.jid)
            }
        }
        
        let jobSet: Set = Set(jobs)
        
        return jobSet.count
    }
    
    public func forDate(_ date: Date) -> [LogRecord] {
        let endDate = date - 86400
        let predicate = NSPredicate(
            format: "timestamp > %@ && timestamp < %@",
            date as CVarArg,
            endDate as CVarArg
        )
        
        return query(predicate)
    }
    
    public func countForDate(_ date: Date? = nil) -> Int {
        if date == nil {
            return 0
        }
        
        let endDate = (date ?? Date()) + 86400
        let predicate = NSPredicate(
            format: "timestamp > %@ && timestamp < %@",
            date! as CVarArg,
            endDate as CVarArg
        )
        
        return count(predicate)
    }
    
    public func weeklyStats(after: (() -> Void)? = nil) async -> (Int, Int, Int) {
        let recordsInPeriod = await waitForRecent(1)
        let wc = countWordsIn(recordsInPeriod)
        let jc = countJobsIn(recordsInPeriod)
        
        defer {
            if let callback = after {
                callback()
            }
        }

        return (wc, jc, recordsInPeriod.count)
    }
    
    public func monthlyStats(after: (() -> Void)? = nil) async -> (Int, Int, Int) {
        let (start, end) = DateHelper.dayAtStartAndEndOfMonth() ?? (nil, nil)
        var recordsInPeriod: [LogRecord] = []
        
        if start != nil && end != nil {
            recordsInPeriod = await waitForRecent(start!, end!)
        } else {
            // if start and end periods could not be determined, default to -4 weeks
            recordsInPeriod = await waitForRecent(4)
        }
        
        let wc = countWordsIn(recordsInPeriod)
        let jc = countJobsIn(recordsInPeriod)
        
        defer {
            if let callback = after {
                callback()
            }
        }
        
        return (wc, jc, recordsInPeriod.count)
    }
    
    public func yearlyStats(after: (() -> Void)? = nil) async -> (Int, Int, Int) {
        let currentWeek = Calendar.current.component(.weekOfYear, from: Date())
        let recordsInPeriod = await waitForRecent(Double(currentWeek))
        let wc = countWordsIn(recordsInPeriod)
        let jc = countJobsIn(recordsInPeriod)
        
        defer {
            if let callback = after {
                callback()
            }
        }
        
        return (wc, jc, recordsInPeriod.count)
    }

    public func createExportableRecordsFrom(_ records: [LogRecord], grouped: Bool? = false) -> String {
        if grouped! {
            return exportableGroupedRecords(records)
        }

        return exportableRecords(records)
    }

    private func exportableGroupedRecords(_ records: [LogRecord]) -> String {
        if records.count == 0 {
            return ""
        }

        var buffer = ""

        let groupedRecords = Dictionary(grouping: records, by: {$0.job}).sorted(by: {$0.key!.jid > $1.key!.jid})

        for group in groupedRecords {
            if group.key != nil {
                let jid = String(Int(group.key!.jid))

                if group.key!.uri != nil {
                    buffer += "\(jid): \(group.key!.uri!.absoluteString)\n"
                } else {
                    buffer += "\(jid)\n"
                }

                for record in group.value {
                    buffer += " - \(record.message!)\n"
                }

                buffer += "\n"
            }
        }

        return buffer
    }

    // TODO: Asana has a max 2000 char limit per entry!
    private func exportableRecords(_ records: [LogRecord]) -> String {
        if records.count == 0 {
            return ""
        }

        var buffer = ""
        var i = 0

        for item in records {
            if let job = item.job {
                let cleaned = CoreDataProjectConfiguration.applyBannedWordsTo(item)

                if let ignoredJobs = job.project?.configuration?.ignoredJobs {
                    if !ignoredJobs.contains(job.jid.string) {
                        let shredableMsg = job.shredable ? " (SR&ED)" : ""
                        var jobSection = ""
                        var line = ""

                        if syncColumns && showColumnIndex {
                            jobSection += " \(String(Int(job.jid)))"
                            line += "\(i) - "
                        } else {
                            jobSection += String(Int(job.jid))
                        }

                        if syncColumns && showColumnJobId {
                            if let uri = job.uri {
                                jobSection += " - \(uri.absoluteString)" + shredableMsg
                            } else {
                                jobSection += shredableMsg
                            }
                        }

                        if syncColumns && showColumnTimestamp {
                            line += "\(item.timestamp!)"
                            line += " - \(jobSection)"
                        } else {
                            line += jobSection
                        }

                        if line.count > 0 {
                            line += " - \(cleaned.message!)\n"
                        } else {
                            line += "\(cleaned.message!)\n"
                        }


                        buffer += line
                    }
                }
            }

            i += 1
        }

        return buffer
    }
    
    private func query(_ predicate: NSPredicate) -> [LogRecord] {
        lock.lock()

        var results: [LogRecord] = []
        let fetch: NSFetchRequest<LogRecord> = LogRecord.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \LogRecord.timestamp, ascending: true)]
        fetch.predicate = predicate
        fetch.returnsDistinctResults = true
        
        do {
            results = try moc!.fetch(fetch)
        } catch {
            print("[error] CoreDataRecords.query Unable to find records for predicate \(predicate.predicateFormat)")
        }
        
        lock.unlock()
        
        return results
    }
    
    private func count(_ predicate: NSPredicate) -> Int {
        lock.lock()
        
        var count = 0
        let fetch: NSFetchRequest<LogRecord> = LogRecord.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \LogRecord.timestamp, ascending: true)]
        fetch.predicate = predicate
        fetch.returnsDistinctResults = true
        
        do {
            count = try moc!.fetch(fetch).count
        } catch {
            print("[error] CoreDataRecords.query Unable to find records for predicate \(predicate.predicateFormat)")
        }
        
        lock.unlock()
        
        return count
    }
}
