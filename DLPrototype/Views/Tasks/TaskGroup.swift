//
//  TaskGroup.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct TaskGroup: View {
    public let index: Int
    public let key: Job
    public var tasks: Dictionary<Job, [LogTask]>

    @State private var minimized: Bool = false

    @AppStorage("widget.tasks.minimizeAll") private var minimizeAll: Bool = false
    
    var body: some View {
        let colour = Color.fromStored(key.colour ?? Theme.rowColourAsDouble)

        if let project = key.project {
            VStack {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    FancyButtonv2(
                        text: project.name!,
                        action: minimize,
                        icon: minimized ? "plus" : "minus",
                        fgColour: minimized ? (colour.isBright() ? .black : .white) : .white,
                        showIcon: false,
                        size: .link
                    )

                    Spacer()
                    FancyButtonv2(
                        text: project.name!,
                        action: minimize,
                        icon: minimized ? "plus" : "minus",
                        fgColour: minimized ? (colour.isBright() ? .black : .white) : .white,
                        showLabel: false,
                        size: .link
                    )
                }
                .padding(8)
            }
            .background(minimized ? colour : Theme.base.opacity(0.3))
            .onAppear(perform: actionOnAppear)

            if !minimized {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Spacer()
                        FancyButtonv2(
                            text: "See all tasks",
                            action: {},
                            icon: "checklist",
                            fgColour: colour.isBright() ? .black : .white,
                            showLabel: false,
                            size: .link,
                            redirect: AnyView(TaskDashboard(defaultSelectedJob: key)),
                            pageType: .tasks,
                            sidebar: AnyView(TaskDashboardSidebar())
                        )

                        FancyButtonv2(
                            text: "Go to project: \(project.name!)",
                            action: {},
                            icon: "folder",
                            fgColour: colour.isBright() ? .black : .white,
                            showLabel: false,
                            size: .link,
                            redirect: AnyView(ProjectsDashboard()),
                            pageType: .projects,
                            sidebar: AnyView(ProjectsDashboardSidebar())
                        )

                        FancyButtonv2(
                            text: "Go to job: \(key.jid.string)",
                            action: {},
                            icon: "hammer",
                            fgColour: colour.isBright() ? .black : .white,
                            showLabel: false,
                            size: .link,
                            redirect: AnyView(JobDashboard(defaultSelectedJob: key)),
                            pageType: .jobs,
                            sidebar: AnyView(JobDashboardSidebar())
                        )
                    }

                    if let subtasks = self.tasks[key] {
                        ForEach(subtasks) { task in
                            TaskViewPlain(task: task)
                        }
                    }
                }
                .foregroundColor(colour.isBright() ? .black : .white)
                .padding(8)
                .background(colour)
                .border(Theme.base.opacity(0.5), width: 1)
            }
        }

        FancyDivider(height: 8)
    }
}

extension TaskGroup {
    private func minimize() -> Void {
        withAnimation {
            minimized.toggle()
        }
    }

    private func actionOnAppear() -> Void {
        minimized = minimizeAll
    }
}
