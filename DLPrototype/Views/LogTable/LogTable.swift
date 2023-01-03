//
//  LogTable.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-01.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct LogTable: View, Identifiable {
    public var id = UUID()
    
    @ObservedObject public var records: Records
    
    @State private var wordCount: Int = 0
    @State private var isReversed: Bool = false
    @State private var wordCountUpdated: Bool = false
    @State public var colourMap: [String: Color] = [
        "11": LogTable.rowColour
    ]
    @State private var colours: [Color] = []
    
    static public var rowColour: Color = Color.gray.opacity(0.2)
    static public var headerColour: Color = Color.blue
    static public var footerColour: Color = Color.gray.opacity(0.5)
    
    private let font: Font = .system(.body, design: .monospaced)
    
    var body: some View {
        HStack {
            table
            tableDetails
        }
        .onAppear(perform: records.applyColourMap)
    }
    
    var table: some View {
        Section {
            Grid(alignment: .top, horizontalSpacing: 1, verticalSpacing: 1) {
                headers
                    .font(font)
                
                ScrollView {
                    rows
                        .font(font)
                }
                
                footer
                    .font(font)
            }
        }
    }
    
    var headers: some View {
        GridRow {
            Group {
                ZStack {
                    LogTable.headerColour
                    Button(action: setIsReversed) {
                        Image(systemName: "arrow.up.arrow.down")
                    }.onChange(of: isReversed) { _ in sort() }
                }
            }
                .frame(width: 50)
            Group {
                ZStack(alignment: .leading) {
                    LogTable.headerColour
                    Text("Timestamp")
                        .padding(10)
                }
            }
                .frame(width: 100)
            Group {
                ZStack(alignment: .leading) {
                    LogTable.headerColour
                    Text("Job ID")
                        .padding(10)
                }
            }
                .frame(width: 100)
            Group {
                ZStack(alignment: .leading) {
                    LogTable.headerColour
                    Text("Message")
                        .padding(10)
                }
            }
            // TODO: temp commented out until perf issues fixed
//            Group {
//                ZStack(alignment: .leading) {
//                    LogTable.headerColour
//                    Text("Actions")
//                        .padding(10)
//                }
//            }
//                .frame(width: 100)
        }
        .frame(height: 40)
    }
    
    var rows: some View {
        VStack(spacing: 1) {
            if records.entries.count > 0 {
                ForEach(records.entries) { entry in
                    LogRow(entry: entry, index: records.entries.firstIndex(of: entry), colour: entry.colour)
                }
            } else {
                LogRowEmpty(message: "No entries found for today", index: 0, colour: LogTable.rowColour)
            }
        }
    }
    
    var footer: some View {
        GridRow {
            Group {
                ZStack {
                    LogTable.footerColour
                    Text("\(records.entries.count)")
                        .padding(10)
                }
            }
                .frame(width: 50)
            Group {
                ZStack(alignment: .leading) {
                    LogTable.footerColour
                }
            }
                .frame(width: 100)
            Group {
                ZStack(alignment: .leading) {
                    LogTable.footerColour
                }
            }
                .frame(width: 100)
            Group {
                ZStack(alignment: .leading) {
                    LogTable.footerColour
                    Text("Word count: \(records.wordCount())")
                        .padding(10)
                }
            }
            // TODO: temp commented out until perf issues fixed
//            Group {
//                ZStack(alignment: .leading) {
//                    LogTable.footerColour
//                }
//            }
//                .frame(width: 100)
        }
        .frame(height: 40)
    }
    
    var tableDetails: some View {
//        LogTableDetails(records: records, colours: colourMap)
        Group {}
    }
    
    private func setIsReversed() -> Void {
        isReversed.toggle()
    }
    
    private func sort() -> Void {
        // just always reverse the records
        records.entries.reverse()
    }
}

struct LogTablePreview: PreviewProvider {
    static var previews: some View {
        LogTable(records: Records())
            .frame(height: 700)
    }
}
