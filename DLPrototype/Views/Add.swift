//
//  Add.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-10.
//  Copyright © 2020 YegCollective. All rights reserved.
//

import SwiftUI

struct Entry: Identifiable {
    let timestamp: String
    let job: String
    let message: String
    let id = UUID()
}

let defaultPickerChoice: CustomPickerItem  = CustomPickerItem(title: "Recent jobs", tag: 0)
let defaultCopiedRow: Entry = Entry(timestamp: "00", job: "11", message: "Row not found")

struct Add : View {
    var category: Category
    
    @State private var text: String = ""
    @State private var jobId: String = ""
    @State private var noLogMessageAlert = false
    @State private var noJobIdAlert = false
    @State private var todayLogLines: String = ""
    @State private var statusMessage: String = ""
    @State private var recentJobs: [CustomPickerItem] = [defaultPickerChoice]
    @State private var jobPickerSelection = 0
    @State private var copiedRow: Entry = defaultCopiedRow
    @State private var tableData: [Entry] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(Image(systemName: "doc.append.fill"))
                    .font(.title)
                Text("Record an entry")
                    .font(.title)
                
                Spacer()
                
                Button(action: { copyAction() }, label: {
                    Image(systemName: "doc.on.doc")
                })
                    .help("Copy all rows")
                
                Button(action: newDayAction, label: {
                    Image(systemName: "sunrise")
                })
                    .help("New day")
            }

            Divider()

            HStack {
                TextField("Job ID", text: $jobId)
                    .frame(width: 100)
                    .font(Font.system(size: 16, design: .default))
                
                Picker("Job", selection: $jobPickerSelection) {
                    ForEach(recentJobs) { item in
                        Text(item.title)
                            .tag(item.tag)
                            .font(Font.system(size: 16, design: .default))
                    }
                }
                    .frame(width: 200)
                    .font(Font.system(size: 16, design: .default))
                    .onChange(of: jobPickerSelection) { _ in
                        // modifies jobId to associate the job to the message
                        jobId = String(jobPickerSelection)
                    }
                
                TextField("Type and hit enter to save...", text: $text)
                    .font(Font.system(size: 16, design: .default))
                    .onSubmit {
                        submitAction()
                    }
            }

            Divider()
            
            Table(tableData) {
                TableColumn("Timestamp", value: \.timestamp)
                    .width(120)
                TableColumn("Job ID", value: \.job)
                    .width(60)
                TableColumn("Message", value: \.message)
            }
//                .contextMenu {
//                    Button("Copy row", action: {
//                        copyAction(tableData[0])
//
//                    })
//                    Divider()
//                    Button(action: {}) { Text("Copy job ID") }
//                    Button(action: {}) { Text("Copy timestamp") }
//                    Button(action: {}) { Text("Copy message") }
//                    Button(action: {}) { Text("Copy row ID") }
//                }
            
            HStack {
                Text(statusMessage)
            }
        }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .padding()
            .onAppear(perform: populateTodayView)
    }
    
//    private func copyRow() -> Void {
//        print($0)
//        print($selection.wrappedValue)
//        print("tapped")
//    }
    
    /// Pull the recent job IDs from today's log entries
    private func buildRecentJobIdList() -> Void {
        let todayLines = readTodayLines()
        var todaysJobs: [Int] = []
        
        if (!todayLines.isEmpty) {
            todayLines.forEach { line in
                let lineParts = line.components(separatedBy: " - ")
                
                if lineParts.count > 1 {
                    let timestamp = Int(lineParts[1]) ?? 0

                    todaysJobs.append(timestamp)
                }
            }
            
            // remove duplicates
            var uniqueJobsToday = Array(Set(todaysJobs))
            // sort unique job ID list numerically
            uniqueJobsToday.sort()
            
            resetPickerToDefault()
            
            for job in uniqueJobsToday {
                let pickerJob = CustomPickerItem(title: String(job), tag: job)
                recentJobs.append(pickerJob)
            }
        }
    }
    
    /// Resets the recentJobs picker to it's default state by removing all elements and appending the default option
    private func resetPickerToDefault() -> Void {
        recentJobs.removeAll()
        recentJobs.append(defaultPickerChoice)
    }
    
    private func newDayAction() -> Void {
        logNewDay()
        clearTodayView()
        
        statusMessage = "New day!"
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            statusMessage = ""
            
            timer.invalidate()
        }
    }
    
    private func copyAction(data: String? = nil) -> Void {
        let pasteBoard = NSPasteboard.general
        
        if var data = data {
            data = readToday()
        }
        
        pasteBoard.clearContents()
        pasteBoard.setString(data!, forType: .string)
        
        statusMessage = "Copied!"
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            statusMessage = ""
            
            timer.invalidate()
        }
    }
    
    private func submitAction() -> Void {
        if self.$text.wrappedValue != "" && self.$jobId.wrappedValue != "" {
            self.logLine()
            
            self.$text.wrappedValue = ""
            self.populateTodayView()
        } else {
            print("You have to type something")
        }
    }
    
    private func populateTodayView() -> Void {
        // read log data into memory
        todayLogLines = readToday()
        // convert log data into [Entry]
        tableData = readTodayTable()
        // update the recent job picker
        buildRecentJobIdList()
    }
    
    private func clearTodayView() -> Void {
        todayLogLines = ""
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    private func writeToLog(output: Data) -> Void {
        let fileName = "\(category.title).log"
        let filePath = getDocumentsDirectory().appendingPathComponent(fileName)
        
        if let fileHandle = try? FileHandle(forWritingTo: filePath) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(output)
            fileHandle.closeFile()
        }
    }
    
    private func logNewDay() -> Void {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let date = formatter.string(from: Date())
        
        guard let line: Data = ("\n=========================\n\(date)\n=========================").data(using: String.Encoding.utf8) else { return }
        
        writeToLog(output: line)
    }
    
    private func logLine() -> Void {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let date = formatter.string(from: Date())
        
        guard let line: Data = ("\n\(date) - \(self.$jobId.wrappedValue) - \(self.$text.wrappedValue)").data(using: String.Encoding.utf8) else { return }
        
        writeToLog(output: line)
    }
    
    private func readToday() -> String {
        return readTodayLines().joined(separator: "\n")
    }
    
    private func readTodayLines() -> [String] {
        var lines: [String] = []

        let log = getDocumentsDirectory().appendingPathComponent("\(category.title).log")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let date = formatter.string(from: Date())
            
        if let logLines = try? String(contentsOf: log) {
            for line in logLines.components(separatedBy: .newlines) {
                if line.hasPrefix(date) {
                    lines.append(line)
                }
            }
        }
        
        return lines
    }
    
    private func readTodayTable() -> [Entry] {
        var data = readTodayLines()
        var entries: [Entry] = []
        
        guard !data.isEmpty || data.count == 1 else {
            let entry = Entry(timestamp: "0", job: "0", message: "No results for that search term or date")
            entries.append(entry)
            
            return entries;
        }
        
        // removes the "new day" entry
        data.removeFirst()
        
        for line in data {
            let parts = line.components(separatedBy: " - ")
            
            if parts.count > 1 {
                let entry = Entry(timestamp: parts[0], job: parts[1], message: parts[2])
                
                entries.append(entry)
            }
        }
        
        return entries
    }
}
