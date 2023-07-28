//
//  Dashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct Dashboard: View {
    static public let id: UUID = UUID()

    @State public var searching: Bool = false

    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var crm: CoreDataRecords
    @EnvironmentObject public var ce: CoreDataCalendarEvent
    @EnvironmentObject public var jm: CoreDataJob
    @EnvironmentObject public var updater: ViewUpdater
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            FindDashboard(searching: $searching)
            FancyDivider()

            if !searching {
                shortcuts

                Widgets()
                    .environmentObject(crm)
                    .environmentObject(ce)
            }
        }
        .font(Theme.font)
        .padding()
        .background(Theme.toolbarColour)
    }

    @ViewBuilder private var shortcuts: some View {
        HStack {
            FancyButtonv2(
                text: "New Record",
                action: {},
                icon: "doc.append.fill",
                showLabel: true,
                size: .medium,
                redirect: AnyView(
                    Today()
                        .environmentObject(jm)
                        .environmentObject(ce)
                        .environmentObject(updater)
                ),
                pageType: .today
            )

            FancyButtonv2(
                text: "New Note",
                action: {},
                icon: "note.text.badge.plus",
                showLabel: true,
                size: .medium,
                redirect: AnyView(
                    NoteCreate()
                        .environmentObject(jm)
                        .environmentObject(updater)
                ),
                pageType: .notes
            )

            FancyButtonv2(
                text: "New Task",
                action: {},
                icon: "plus",
                showLabel: true,
                size: .medium,
                redirect: AnyView(
                    TaskDashboard()
                        .environmentObject(jm)
                        .environmentObject(updater)
                ),
                pageType: .tasks
            )

            FancyButtonv2(
                text: "New Project",
                action: {},
                icon: "folder.badge.plus",
                showLabel: true,
                size: .medium,
                redirect: AnyView(
                    ProjectCreate()
                        .environmentObject(jm)
                        .environmentObject(updater)
                ),
                pageType: .projects
            )

//                FancyButtonv2(
//                    text: "New Job",
//                    action: {},
//                    icon: "plus",
//                    showLabel: true,
//                    size: .medium,
//                    redirect: AnyView(
//                        TaskDashboard()
//                    )
//            ,
//            pageType: .jobs
//                )
        }
        FancyDivider()
    }
}
