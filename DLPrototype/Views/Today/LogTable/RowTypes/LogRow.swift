//
//  LogRow.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-01.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct LogRow: View, Identifiable {
    public var entry: Entry
    public var index: Array<Entry>.Index?
    public var colour: Color
    public var id = UUID()
    
    @Binding public var selectedJob: String
    
    @State public var isEditing: Bool = false
    @State public var isDeleting: Bool = false
    @State public var message: String = ""
    @State public var job: String = ""
    @State public var timestamp: String = ""
    @State public var aIndex: String = "0"
    @State public var activeColour: Color = Theme.rowColour
    @State public var projectColHelpText: String = ""
    
    @EnvironmentObject public var jm: CoreDataJob
    
    @AppStorage("tigerStriped") private var tigerStriped = false
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures = false
    @AppStorage("showExperiment.actions") private var showExperimentActions = false
    @AppStorage("today.showColumnIndex") public var showColumnIndex: Bool = true
    @AppStorage("today.showColumnTimestamp") public var showColumnTimestamp: Bool = true
    @AppStorage("today.showColumnJobId") public var showColumnJobId: Bool = true
    @AppStorage("today.showColumnActions") public var showColumnActions: Bool = false
    
    var body: some View {
        HStack(spacing: 1) {
            GridRow {
                Column(
                    colour: (entry.jobObject != nil  && entry.jobObject!.project != nil ? Color.fromStored(entry.jobObject!.project!.colour ?? Theme.rowColourAsDouble) : applyColour()),
                    textColour: rowTextColour(),
                    text: $projectColHelpText
                )
                .frame(width: 5)

                if showColumnIndex {
                    Column(
                        colour: applyColour(),
                        textColour: rowTextColour(),
                        text: $aIndex
                    )
                    .frame(maxWidth: 50)
                }

                if showColumnTimestamp {
                    EditableColumn(
                        type: "timestamp",
                        colour: applyColour(),
                        textColour: rowTextColour(),
                        index: index,
                        alignment: .center,
                        isEditing: $isEditing,
                        isDeleting: $isDeleting,
                        text: $timestamp
                    )
                    .frame(maxWidth: 101)
                    .help(entry.timestamp)
                }

                if showColumnJobId {
                    EditableColumn(
                        type: "job",
                        colour: applyColour(),
                        textColour: rowTextColour(),
                        index: index,
                        alignment: .center,
                        isEditing: $isEditing,
                        isDeleting: $isDeleting,
                        text: $job,
                        url: (entry.jobObject != nil && entry.jobObject!.uri != nil ? entry.jobObject!.uri : nil),
                        job: entry.jobObject
                    )
                    .frame(maxWidth: 80)
                }
                
                EditableColumn(
                    type: "message",
                    colour: applyColour(),
                    textColour: rowTextColour(),
                    index: index,
                    isEditing: $isEditing,
                    isDeleting: $isDeleting,
                    text: $message
                )
                
                if showExperimentalFeatures {
                    if showColumnActions {
                        Group {
                            ZStack {
                                applyColour()
                                
                                LogRowActions(
                                    entry: entry,
                                    colour: rowTextColour(),
                                    index: index,
                                    isEditing: $isEditing,
                                    isDeleting: $isDeleting
                                )
                            }
                        }
                        .frame(maxWidth: 100)
                    }
                }
            }
            .contextMenu { contextMenu }
        }
        .defaultAppStorage(.standard)
        .onAppear(perform: setEditableValues)
        .onChange(of: timestamp) { _ in
            setEditableValues()
        }
//        .onHover(perform: onHover)
    }
    
    @ViewBuilder private var contextMenu: some View {
        if entry.jobObject != nil {
            if entry.jobObject!.uri != nil {
                Link(destination: entry.jobObject!.uri!, label: {
                    Text("Open job link in browser")
                })
            }

            Menu("Copy") {
                if entry.jobObject!.uri != nil {
                    Button(action: {ClipboardHelper.copy(entry.jobObject!.uri!.absoluteString)}, label: {
                        Text("Job URL")
                    })
                }
                
                Button(action: {ClipboardHelper.copy(entry.jobObject!.jid.string)}, label: {
                    Text("Job ID")
                })
                
                Button(action: {ClipboardHelper.copy(colour.description.debugDescription)}, label: {
                    Text("Job colour code")
                })
                
                Button(action: {ClipboardHelper.copy(entry.message)}, label: {
                    Text("Message")
                })
            }
            
            Menu("Go to"){
                NavigationLink(destination: NoteDashboard(defaultSelectedJob: entry.jobObject).environmentObject(jm)) {
                    Text("Notes")
                }
//                .keyboardShortcut("n")
                
                NavigationLink(destination: TaskDashboard(defaultSelectedJob: entry.jobObject!).environmentObject(jm)) {
                    Text("Tasks")
                }
//                .keyboardShortcut("t")
                
                if entry.jobObject!.project != nil {
                    NavigationLink(destination: ProjectView(project: entry.jobObject!.project!).environmentObject(jm)) {
                        Text("Project")
                    }
//                    .keyboardShortcut("p")
                }
                
                NavigationLink(destination: JobDashboard(defaultSelectedJob: entry.jobObject!.jid).environmentObject(jm)) {
                    Text("Job")
                }
                //            .keyboardShortcut("j")
            }

            Menu("Inspect"){
                Text("SR&ED Eligible: " + (entry.jobObject!.shredable ? "Yes" : "No"))
            }
            
            Divider()
            
            Button(action: {setJob(entry.jobObject!.jid.string)}, label: {
                Text("Set job")
            })
        }
    }
    
    private func setJob(_ job: String) -> Void {
        let dotIndex = (job.range(of: ".")?.lowerBound)
        
        if dotIndex != nil {
            selectedJob = String(job.prefix(upTo: dotIndex!))
        }
    }

    private func setEditableValues() -> Void {
        message = entry.message
        job = entry.job
        timestamp = entry.timestamp
        aIndex = adjustedIndexAsString()
    }
    
    // this can be forced to work but it causes perf and state modification problems
    // TODO: maybe show actions on hover?
//    private func onHover(hovering: Bool) -> Void {
//        let oldColour = colour
//
//        if hovering {
//            activeColour = Color.white.opacity(0.1)
//        } else {
//            activeColour = oldColour
//        }
//    }
    
    private func applyColour() -> Color {
        if isEditing {
            return Color.orange
        }

        if isDeleting {
            return Color.red
        }

        if tigerStriped {
            return colour.opacity(index!.isMultiple(of: 2) ? 1 : 0.5)
        }

        return colour
    }
    
    private func rowTextColour() -> Color {
        return colour.isBright() ? Color.black : Color.white
    }
    
    private func adjustedIndex() -> Int {
        var adjusted: Int = Int(index!)
        adjusted += 1

        return adjusted
    }
    
    private func adjustedIndexAsString() -> String {
        let adjusted = adjustedIndex()
        
        return String(adjusted)
    }
}

struct LogTableRowPreview: PreviewProvider {
    @State static public var sj: String = "11.0"
    
    static var previews: some View {
        VStack {
            LogRow(entry: Entry(timestamp: "2023-01-01 19:48", job: "88888", message: "Hello, world"), index: 0, colour: Theme.rowColour, selectedJob: $sj)
            LogRow(entry: Entry(timestamp: "2023-01-01 19:49", job: "11", message: "Hello, world"), index: 1, colour: Theme.rowColour, selectedJob: $sj)
        }
    }
}
