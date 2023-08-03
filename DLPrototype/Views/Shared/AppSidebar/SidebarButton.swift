//
//  SidebarButton.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-27.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct SidebarButton: View, Identifiable {
    public let id: UUID = UUID()
    public var destination: AnyView
    public let pageType: Page
    public var icon: String
    public var label: String
    public var sidebar: AnyView?
    public var showLabel: Bool = true
    public var size: ButtonSize? = .large

    @State private var highlighted: Bool = false

    @EnvironmentObject public var nav: Navigation

    var body: some View {
        let button = FancyButton
        switch(size) {
        case .large:
            button.frame(width: 50, height: 50)
        case .medium:
            button.frame(width: 40, height: 40)
        case .small:
            button.frame(width: 20, height: 20)
        case .link:
            button
        case .none:
            button
        }
    }

    private var FancyButton: some View {
        Button(action: {
            nav.parent = pageType
            nav.view = destination

            if sidebar != nil {
                nav.sidebar = sidebar
            } else {
                nav.sidebar = nil
            }
        }, label: {
            ZStack {
                Theme.toolbarColour
                nav.parent == pageType ? Theme.tabActiveColour : Theme.tabColour

                if nav.parent != pageType {
                    HStack {
                        Spacer()
                        LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .leading, endPoint: .trailing)
                            .opacity(0.6)
                            .blendMode(.softLight)
                            .frame(width: 12)
                    }
                } else {
                    LinearGradient(
                        colors: [(highlighted ? .black : .clear), Theme.toolbarColour],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                    .opacity(0.1)
                }


                Image(systemName: icon)
                    .font(.title)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(highlighted ? .white : .white.opacity(0.8))
            }
        })
        .help(label)
        .buttonStyle(.plain)
        .onHover { inside in
            if inside {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }

            highlighted.toggle()
        }
    }
}
