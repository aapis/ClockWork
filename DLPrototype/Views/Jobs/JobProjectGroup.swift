//
//  JobProjectGroup.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-06.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct JobProjectGroup: View {
    public let index: Int
    public let key: Project
    public var jobs: Dictionary<Project, [Job]>

    @State private var minimized: Bool = false

    @AppStorage("widget.jobpicker.minimizeAll") private var minimizeAll: Bool = false

    var body: some View {
        let colour = Color.fromStored(key.colour ?? Theme.rowColourAsDouble)
        
        VStack {
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                FancyButtonv2(
                    text: key.name!,
                    action: minimize,
                    icon: minimized ? "plus" : "minus",
                    fgColour: minimized ? (colour.isBright() ? .black : .white) : .white,
                    showIcon: false,
                    size: .link
                )
                Spacer()
                FancyButtonv2(
                    text: key.name!,
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
                if let subtasks = self.jobs[key] {
                    HStack(alignment: .top, spacing: 0) {
                        ZStack {
                            colour
                        }
                        .frame(width: 5)

                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(subtasks) { job in
                                JobRowPicker(job: job)
                            }
                        }
                    }
                }
            }
            .foregroundColor(colour.isBright() ? .black : .white)
            .border(Theme.base.opacity(0.5), width: 1)
        }

        FancyDivider(height: 8)
    }
}

extension JobProjectGroup {
    private func minimize() -> Void {
        withAnimation {
            minimized.toggle()
        }
    }

    private func actionOnAppear() -> Void {
        minimized = minimizeAll
    }
}