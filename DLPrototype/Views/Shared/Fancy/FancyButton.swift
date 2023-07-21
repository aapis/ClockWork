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
        case .small:
            padding = 0
        case .medium:
            padding = 5
        case .large:
            padding = 10
        }
    }
}

public enum ButtonType {
    case destructive, standard, primary

    var colours: [Color] {
        switch self {
        case .primary:
            return [Color.blue, Color(hue: 216.0/100, saturation: 85.0/100, brightness: 34.0/100)]
        case .destructive:
            return [Color.red, Color(hue: 0.0/100, saturation: 84.0/100, brightness: 43.0/100)]
        case .standard:
            return [Color.white, Color.gray]
        }
    }
}

public struct FancyButtonv2: View {
    public var text: String
    public var action: () -> Void
    public var icon: String? = "checkmark.circle"
    public var altIcon: String? = "checkmark.circle"
    public var transparent: Bool? = false
    public var showLabel: Bool? = true
    public var showIcon: Bool? = true
    public var size: ButtonSize = .medium
    public var type: ButtonType = .standard

    @State private var padding: CGFloat = 10
    @State private var highlighted: Bool = false

    public var body: some View {
        VStack {
            Button(action: action, label: {
                ZStack {
                    Background

                    HStack {
                        if showIcon! {
                            Image(systemName: icon!)
                                .symbolRenderingMode(.hierarchical)
                        }

                        if showLabel! {
                            Text(text)
                        }
                    }
                    .padding()
                }
                .frame(width: 50, height: 50)
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

                    highlighted.toggle()
                }
            })
            .buttonStyle(.borderless)
            .onAppear(perform: onAppear)
        }
    }

    private var Background: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: type.colours), startPoint: .topLeading, endPoint: .bottomTrailing)
                .mask(
                    RoundedRectangle(cornerRadius: 5)
                    //                                .foregroundColor(highlighted ? fgColourEffect() : fgColour!)

                )
//                .shadow(color: .black.opacity(0.5), radius: 3)
        }
    }

    private func onAppear() -> Void {
        switch size {
        case .small:
            padding = 0
        case .medium:
            padding = 5
        case .large:
            padding = 10
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
