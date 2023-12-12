//
//  CompanyCreate.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-12.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct CompanyCreate: View {
    @State private var name: String = ""
    @State private var abbreviation: String = ""

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    Title(text: "Create a company")
                    Spacer()
                }
                
                FancyTextField(placeholder: "Legal name", lineLimit: 1, onSubmit: {}, text: $name)
                FancyTextField(placeholder: "Abbreviation (i.e. City of New York = CONY)", lineLimit: 1, onSubmit: {}, text: $abbreviation)
                FancyDivider()

                HStack {
                    Spacer()
                    FancyButtonv2(
                        text: "Create",
                        action: create,
                        size: .medium,
                        redirect: AnyView(CompanyDashboard()),
                        pageType: .projects,
                        sidebar: AnyView(DefaultCompanySidebar())
                    )
                }

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
    }
}

extension CompanyCreate {
    private func create() -> Void {
        let company = Company(context: moc)
        company.pid = Int64.random(in: 1..<1000000000000001)
        company.name = name
        company.createdDate = Date()
        company.colour = Color.randomStorable()
        company.alive = true
        company.id = UUID()
        company.abbreviation = abbreviation

        PersistenceController.shared.save()
    }
}