//
//  LinkDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct RecentSearch: Identifiable {
    let id: UUID = UUID()
    var term: String
}

struct FindDashboard: View {
    @State private var searchText: String = ""
    @State private var showRecords: Bool = true
    @State private var showNotes: Bool = true
    @State private var showTasks: Bool = true
    @State private var showProjects: Bool = true
    @State private var showJobs: Bool = true
    @State private var allowAlive: Bool = true
    
    @EnvironmentObject public var jm: CoreDataJob
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                search

                Spacer()
            }
            .font(Theme.font)
            .padding()
        }
        .background(Theme.toolbarColour)
    }
    
    @ViewBuilder
    var search: some View {
        HStack {
            Title(text: "Find", image: "magnifyingglass")
            Spacer()
        }
        
        Grid(horizontalSpacing: 0, verticalSpacing: 1) {
            GridRow {
                SearchBar(
                    text: $searchText,
                    disabled: false,
                    placeholder: "Search"
                )
            }
            
            GridRow {
                ZStack(alignment: .leading) {
                    Theme.subHeaderColour
                    
                    HStack {
                        Toggle("Records", isOn: $showRecords)
                        Toggle("Notes", isOn: $showNotes)
                        Toggle("Tasks", isOn: $showTasks)
                        Toggle("Projects", isOn: $showProjects)
                        Toggle("Jobs", isOn: $showJobs)
                        // TODO: re-add at some point
//                        Spacer()
//                        Toggle("Show alive", isOn: $allowAlive)
                    }
                    .padding([.leading, .trailing], 10)
                }
            }
            .frame(height: 40)
            
            FancyDivider()
            
            Results(
                text: $searchText,
                showRecords: $showRecords,
                showNotes: $showNotes,
                showTasks: $showTasks,
                showProjects: $showProjects,
                showJobs: $showJobs,
                allowAlive: $allowAlive
            )
                .environmentObject(jm)
        }
    }
}