//
//  NoteSearchWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct NoteSearchWidget: View {
    public let title: String = "Notes"

    @State private var minimized: Bool = false
    @State private var query: String = ""
    @State private var isLoading: Bool = false
    @State private var isSettingsPresented: Bool = false
    @State private var grouped: Dictionary<Job, [Note]> = [:]
    @State private var sortedJobs: [EnumeratedSequence<Dictionary<Job, [Note]>.Keys>.Element] = []

    @FetchRequest public var resource: FetchedResults<Note>

    @AppStorage("widget.notesearch.showSearch") private var showSearch: Bool = true
    @AppStorage("widget.notesearch.minimizeAll") private var minimizeAll: Bool = false
//    @AppStorage("widget.notesearch.onlyRecent") private var onlyRecent: Bool = true

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        if isLoading {
            WidgetLoading()
        } else {
            NoteSearchWidget
        }
    }

    var NoteSearchWidget: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack {
                    if let parent = nav.parent {
                        FancyButtonv2(
                            text: "Minimize",
                            action: actionMinimize,
                            icon: minimized ? "plus" : "minus",
                            showLabel: false,
                            type: .clear
                        )
                        .frame(width: 30, height: 30)

                        if parent != .notes {
                            Text(title)
                                .padding(.trailing, 10)
                        } else {
                            Text("Search notes")
                        }
                    }
                }
                .padding(5)

                Spacer()

                HStack {
                    FancyButtonv2(
                        text: "Settings",
                        action: actionSettings,
                        icon: "gear",
                        showLabel: false,
                        type: .clear
                    )
                    .frame(width: 30, height: 30)
                }
                .padding(5)
            }
            .background(Theme.base.opacity(0.2))

            VStack {
                if !minimized {
                    if isSettingsPresented {
                        Settings(
                            showSearch: $showSearch,
                            minimizeAll: $minimizeAll
                        )
                    } else {
                        if showSearch {
                            VStack {
                                SearchBar(text: $query, disabled: minimized)
                                    .onChange(of: query, perform: actionOnSearch)
                                    .onChange(of: nav.session.job, perform: actionOnChangeJob)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 0) {
                            if grouped.count > 0 {
                                ForEach(Array(grouped.keys.enumerated()), id: \.element) { index, key in
                                    NoteGroup(index: index, key: key, notes: grouped)
                                }
                            } else {
                                SidebarItem(
                                    data: "No notes matching query",
                                    help: "No notes matching query",
                                    role: .important
                                )
                            }
                            FancyDivider()
                        }
                    }
                } else {
                    HStack {
                        Text("\(grouped.count) notes")
                        Spacer()
                    }
                }
            }
            .padding(8)
            .background(Theme.base.opacity(0.2))
        }
        .onAppear(perform: actionOnAppear)

    }
}

extension NoteSearchWidget {
    public init() {
        _resource = CoreDataNotes.fetchNotes()
    }

    private func actionOnSearch(term: String) -> Void {
        if term.count > 1 {
            var filtered = grouped.filter {
                (
                    $0.value.contains(where: {$0.mJob!.jid.string.caseInsensitiveCompare(term) == .orderedSame})
                    ||
                    (
                        $0.value.contains(where: {$0.mJob!.jid.string.starts(with: term)})
                    )
                )
            }

            if term.starts(with: "https://") {
                filtered = grouped.filter {
                    (
                        $0.value.contains(where: {$0.mJob!.uri?.absoluteString.caseInsensitiveCompare(term) == .orderedSame})
                        ||
                        (
                            $0.value.contains(where: {$0.mJob!.uri?.absoluteString.contains(term) ?? false})
                            ||
                            $0.value.contains(where: {$0.mJob!.uri?.absoluteString.starts(with: term) ?? false})
                        )
                    )
                }
            }

            grouped = filtered
        } else {
            actionOnAppear()
        }
    }

    private func actionOnAppear() -> Void {
        grouped = Dictionary(grouping: resource, by: {$0.mJob!})
        sortedJobs = Array(grouped.keys.enumerated())
            .sorted(by: ({$0.element.jid < $1.element.jid}))
    }

    private func actionMinimize() -> Void {
        minimized.toggle()
    }

    private func actionSettings() -> Void {
        isSettingsPresented.toggle()
    }

    private func actionOnChangeJob(job: Job?) -> Void {
        if let jerb = job {
            query = jerb.jid.string
//            grouped = sgrouped
        }
    }
}

extension NoteSearchWidget {
    struct Settings: View {
        private let title: String = "Widget Settings"

        @Binding public var showSearch: Bool
        @Binding public var minimizeAll: Bool

        var body: some View {
            ZStack(alignment: .leading) {
                Theme.base.opacity(0.3)

                VStack(alignment: .leading) {
                    FancySubTitle(text: title)
                    Toggle("Show search bar", isOn: $showSearch)
                    Toggle("Minimize all groups", isOn: $minimizeAll)
                    Spacer()
                    FancyDivider()
                }
                .padding()
            }
        }
    }
}
