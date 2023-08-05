//
//  ProjectsWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-05.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct ProjectsWidget: View {
    public let title: String = "Projects"

    @State private var minimized: Bool = false
    @State private var query: String = ""
    @State private var listItems: [Project] = []

    @FetchRequest public var resource: FetchedResults<Project>

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
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
                SearchBar(text: $query, disabled: minimized, placeholder: "Search projects...")
                    .onChange(of: query, perform: actionOnSearch)

                VStack(alignment: .leading, spacing: 5) {
                    if listItems.count > 0 {
                        ForEach(listItems) { project in
                            ProjectRowPlain(project: project)
                        }
                    } else {
                        SidebarItem(
                            data: "No projects matching query",
                            help: "No projects matching query",
                            role: .important
                        )
                    }
                    FancyDivider()
                }
            }
        }
        .onAppear(perform: actionOnAppear)
    }
}

extension ProjectsWidget {
    public init() {
        _resource = CoreDataProjects.fetchProjects()
    }

    private func getRecent() -> [Project] {
        var projects: [Project] = []

        if resource.count > 0 {
            let items = resource[..<5]

            for item in items {
                projects.append(item)
            }
        }

        return projects
    }

    private func actionOnAppear() -> Void {
        setListItems(getRecent())
    }

    private func actionOnSearch(term: String) -> Void {
        if term.count > 3 {
            setListItems(
                resource.filter {
                    $0.name?.caseInsensitiveCompare(term) == .orderedSame
                    ||
                    (
                        $0.name?.contains(term) ?? false
                        ||
                        $0.name?.starts(with: term) ?? false
                    )
                }
            )
        } else {
            setListItems(getRecent())
        }
    }

    private func actionMinimize() -> Void {
        withAnimation {
            minimized.toggle()
        }
    }

    private func setListItems(_ list: [Project]) -> Void {
        listItems = list
    }
}
