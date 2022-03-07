//
//  Search.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-10.
//  Copyright © 2020 YegCollective. All rights reserved.
//

import SwiftUI

struct CustomPickerItem: Identifiable {
    var id = UUID()
    var title: String
    var tag: Int
}

struct Search: View {
    var category: Category
    
    @State private var searchByDate: String = ""
    @State private var searchText: String = ""
    @State private var searchResults: String = ""
    @State private var dateList: [CustomPickerItem] = [CustomPickerItem(title: "Default", tag: 0)]
    @State private var selection = 0
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(Image(systemName: "magnifyingglass.circle.fill"))
                    .font(.title)
                Text("Find records")
                    .font(.title)
            }
            
            Divider()
            
            HStack {
                // formerly in ComboBox
                Picker("Date", selection: $selection) {
                    ForEach(dateList) { item in
                        Text(item.title)
                            .tag(item.tag)
                            .font(Font.system(size: 16, design: .default))
                    }
                }
                    .frame(width: 200)
                    .font(Font.system(size: 16, design: .default))
                    .onAppear(perform: {
                        self.dateList = self.generateDateList()
                    })

                TextField("Search terms", text: $searchText)
                    .font(Font.system(size: 16, design: .default))
                
                Button(action: self.findAction, label: {
                    Image(systemName: "magnifyingglass")
                })
                    .background(Color.accentColor)
                    .help("Search")
                
                Button(action: self.findAndCopy, label: {
                    Image(systemName: "doc.on.doc")
                })
                    .background(Color.accentColor)
                    .help("Search and copy results")
            }
            
            Divider()
            
            Table(getDatesForTable()) {
                TableColumn("Timestamp", value: \.timestamp)
                    .width(120)
                TableColumn("Job ID", value: \.job)
                    .width(60)
                TableColumn("Message", value: \.message)
            }
        }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .padding()
    }
    
    private func findAction() -> Void {
        self.$searchByDate.wrappedValue = self.dateList[self.$selection.wrappedValue].title
        
        self.setSearchResults()
    }
    
    private func copyAction() -> Void {
        let pasteBoard = NSPasteboard.general
        let data = self.getAllRows()
        
        pasteBoard.clearContents()
        pasteBoard.setString(data, forType: .string)
    }
    
    private func findAndCopy() -> Void {
        self.findAction()
        self.copyAction()
    }
        
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    private func setSearchResults() -> Void {
        self.$searchResults.wrappedValue = getAllRows()
    }
    
    private func getAllRows() -> String {
        let lines: [String] = getFilteredRows()
        
        return lines.joined(separator: "\n")
    }
    
    private func getFilteredRows() -> [String] {
        var lines: [String] = []

        let log = getDocumentsDirectory().appendingPathComponent("\(category.title).log")
        let term = getSearchTerm()
        
        if let logLines = try? String(contentsOf: log) {
            for line in logLines.components(separatedBy: .newlines) {
                if line.contains(term) {
                    lines.append(line)
                }
            }
        }
        
        return lines
    }
    
    private func getSearchTerm() -> String {
        var term = ""
        
        switch self.$searchText.wrappedValue {
        case "":
            term = self.$searchByDate.wrappedValue
        case "today":
            term = getRelativeDate(0)
        case "yesterday":
            term = getRelativeDate(-1)
        default:
            term = self.$searchText.wrappedValue
        }
        
        return term
    }
    
    private func getRelativeDate(_ relativeDate: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let calendar = Calendar.current
        
        let midnight = calendar.startOfDay(for: Date())
        let requestedDate = calendar.date(byAdding: .day, value: relativeDate, to: midnight)!
        let formatted = formatter.string(from: requestedDate)
        
        return formatted
    }
    
    private func generateDateList() -> [CustomPickerItem] {
        var dates: [CustomPickerItem] = []
        
        for i in 0...30 {
            dates.append(CustomPickerItem(title: getRelativeDate(i * -1), tag: i))
        }
        
        return dates
    }
    
    private func getDatesForTable() -> [Entry] {
        var data = getFilteredRows()
        var entries: [Entry] = []
        
        if data.isEmpty {
            return entries;
        }
        
        // removes the "new day" entry
        data.removeFirst()
        
        for line in data {
            let parts = line.components(separatedBy: " - ")
            let entry = Entry(timestamp: parts[0], job: parts[1], message: parts[2])
            
            entries.append(entry)
        }
        
        return entries
    }
}
