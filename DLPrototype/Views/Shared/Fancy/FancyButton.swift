//
//  FancyButton.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-07.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct FancyButton: View {
    public var text: String
    public var action: () -> Void
    public var icon: String? = "checkmark.circle"
    public var altIcon: String? = "checkmark.circle"
    public var transparent: Bool? = false
    public var showLabel: Bool? = true
    public var showIcon: Bool? = true
    public var fgColour: Color?
    public var size: ButtonSize = .medium
    
    @State private var padding: CGFloat = 10
    
    var body: some View {
        VStack {
            Button(action: action, label: {
                HStack {
                    if showIcon! {
                        Image(systemName: icon!)
                            .foregroundColor(fgColour != nil ? fgColour : .white)
                    }
                    
                    if showLabel! {
                        Text(text)
                    }
                }
                .foregroundColor(Color.white)
                .font(.title3)
                .padding(padding)
                .help(text)
                .onHover { inside in
                    if inside {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            })
            .buttonStyle(.borderless)
            .background(transparent! ? Color.clear : Color.black.opacity(0.2))
            .onAppear(perform: onAppear)
        }
    }
    
    private func onAppear() -> Void {
        switch size {
        case .small, .link:
            padding = 0
        case .medium:
            padding = 5
        case .large:
            padding = 10
        }
    }
}

public enum ButtonType {
    case destructive, standard, primary, star

    var colours: [Color] {
        switch self {
        case .primary:
            return [Color.green, Color.blue]
        case .destructive:
            return [Color.red, Color(hue: 0.0/100, saturation: 84.0/100, brightness: 43.0/100)]
        case .star:
            return [Color.yellow, Color.orange]
        case .standard:
            return [Theme.headerColour, Color.black]
        }
    }

    var textColour: Color {
        switch self {
        case .primary:
            return Color.white
        case .destructive:
            return Color.white
        case .star:
            return Color.black
        case .standard:
            return Color.white
        }
    }

    var highlightColour: Color {
        switch self {
        case .primary:
            return Color.green
        case .destructive:
            return Color.red
        case .star:
            return Color.yellow
        case .standard:
            return Theme.headerColour
        }
    }
}

public struct FancyButtonv2: View {
    public var text: String
    public var action: () -> Void
    public var icon: String? = "checkmark.circle"
    public var fgColour: Color?
    public var transparent: Bool? = false
    public var showLabel: Bool? = true
    public var showIcon: Bool? = true
    public var size: ButtonSize = .small
    public var type: ButtonType = .standard
    public var redirect: AnyView? = nil
    public var pageType: Page? = nil

    @EnvironmentObject public var nav: Navigation

    @State private var padding: CGFloat = 10
    @State private var highlighted: Bool = false

    public var body: some View {
        VStack {
            if let destination = redirect {
                Button(action: {
                    nav.view = destination

                    if let pType = pageType {
                        nav.parent = pType
                    }
                }) {
                    button
                }
                .buttonStyle(.plain)
            } else {
                Button(action: action) {
                    button
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var button: some View {
        ZStack {
            if highlighted {
                HighlightedBackground
            } else {
                Background
            }

            HStack {
                if showIcon! {
                    Image(systemName: icon!)
                        .symbolRenderingMode(.hierarchical)
                        .font(.title2)
                        .foregroundColor(fgColour != nil ? fgColour : type.textColour)
                }

                if showLabel! {
                    Text(text)
                        .foregroundColor(fgColour != nil ? fgColour : type.textColour)
                }
            }
            .padding(5)
        }
        .frame(maxWidth: buttonFrameWidth(), maxHeight: 40)
        .foregroundColor(Color.white)
        .font(.title3)
        .help(text)
        .onHover { inside in
            if inside {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }

            highlighted.toggle()
        }
    }

    private var Background: some View {
        ZStack {
            type.colours.first
        }
        .mask(
            RoundedRectangle(cornerRadius: 3)
        )
    }

    private var HighlightedBackground: some View {
        ZStack {
            type.colours.first
            LinearGradient(gradient: Gradient(colors: type.colours), startPoint: .top, endPoint: .bottom)
                .blendMode(.softLight)
                .opacity(0.3)
        }
        .mask(
            RoundedRectangle(cornerRadius: 3)
        )
    }

    private func buttonFrameWidth() -> CGFloat {
        switch size {
        case .small, .link:
            return 40
        case .medium:
            return 200
        case .large:
            return 200
        }
    }

    private func fgColourEffect() -> Color {
//        let gradient = LinearGradient(colors: [fgColour, Color.black])
        return Color.black
    }
}

struct FancyButtonPreview: PreviewProvider {
    static var previews: some View {        
        FancyButton(text: "Button text", action: {}, icon: "checkmark.circle")
    }
}
