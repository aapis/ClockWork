//
//  RecentJobsWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct RecentJobsWidget: View {
    public let title: String = "Recent Jobs"

    @State private var minimized: Bool = false
    @State private var query: String = ""
    @State private var listItems: [Job] = []

    @FetchRequest public var resource: FetchedResults<Job>

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let parent = nav.parent {
                    if parent != .jobs {
                        FancySubTitle(text: "Jobs")
                    }
                }

                Spacer()
                FancyButtonv2(
                    text: "Minimize",
                    action: actionMinimize,
                    icon: minimized ? "plus" : "minus",
                    showLabel: false,
                    type: .white
                )
                .frame(width: 30, height: 30)
            }

            if !minimized {
                VStack {
                    SearchBar(text: $query, disabled: minimized, placeholder: "Search jobs...")
                        .onChange(of: query, perform: actionOnSearch)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(listItems) { job in
                        JobRowPlain(job: job)
                    }
                    FancyDivider()
                }
            }
        }
        .onAppear(perform: actionOnAppear)
    }
}

extension RecentJobsWidget {
    public init() {
        _resource = CoreDataJob.fetchRecentJobs()
    }

    private func getRecent() -> [Job] {
        var jobs: [Job] = []

        if resource.count > 0 {
            let items = resource[..<5]

            for item in items {
                jobs.append(item)
            }
        }

        return jobs
    }
    
    private func actionMinimize() -> Void {
        withAnimation {
            minimized.toggle()
        }
    }

    private func actionOnAppear() -> Void {
        setListItems(getRecent())
    }

    private func actionOnSearch(term: String) -> Void {
        if term.count > 1 {
            setListItems(
                resource.filter {
                    $0.jid.string.caseInsensitiveCompare(term) == .orderedSame
                    ||
                    (
                        $0.jid.string.contains(term)
                        ||
                        $0.jid.string.starts(with: term)
                    )
                }
            )
        } else {
            setListItems(getRecent())
        }
    }

    private func setListItems(_ list: [Job]) -> Void {
        listItems = list
    }
}
