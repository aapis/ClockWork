//
//  SidebarItem.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-01.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

public enum ItemRole {
    case important, standard

    var colour: Color {
        switch self {
        case .important:
            return Color.red
        case .standard:
            return Color.black
        }
    }
}

public enum ItemType {
    case standard, thin

    var iconFrameSize: CGFloat {
        switch self {
        case .standard:
            return 50
        case .thin:
            return 30
        }
    }

    var frameHeight: CGFloat {
        switch self {
        case .standard:
            return 50
        case .thin:
            return 30
        }
    }

    var padding: CGFloat {
        switch self {
        case .standard:
            return 10
        case .thin:
            return 5
        }
    }

    var fontSize: Font {
        switch self {
        case .standard:
            return .body
        case .thin:
            return .caption
        }
    }
}

public enum ItemOrientation {
    case left, right
}

struct SidebarItem: View, Identifiable {
    public let id: UUID = UUID()
    public var data: String
    public var help: String
    public var icon: String?
    public var orientation: ItemOrientation = .left
    public var role: ItemRole = .standard
    public var type: ItemType = .standard
    public var action: (() -> Void)?
    public var showBorder: Bool = true
    public var showButton: Bool = true

    @State private var highlighted: Bool = false
    @State private var altIcon: String?
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if orientation == .left {
                if showButton {ItemIcon}
                ItemLabel
            } else {
                ItemLabel
                if showButton {ItemIcon}
            }
        }
        .border(.black.opacity(0.2), width: (showBorder ? 1 : 0))
        .mask(
            RoundedRectangle(cornerRadius: 4)
        )
        .useDefaultHover({ inside in highlighted = inside})
        .onAppear(perform: actionOnAppear)
        .contextMenu {
            Button("Copy \(data)") {
                ClipboardHelper.copy(data)
            }
        }
    }

    @ViewBuilder private var ItemIcon: some View {
        if let ic = icon {
            ZStack(alignment: .center) {
                if role != .important {
                    role.colour.opacity(highlighted ? 0.15 : 0.08)
                } else {
                    role.colour
                }

                Button(action: doAction) {
                    if let alt = altIcon {
                        if highlighted {
                            Image(systemName: alt)
                                .font(.title2)
                                .frame(maxWidth: 30, maxHeight: 30)
                        } else {
                            Image(systemName: ic)
                                .font(.title2)
                                .frame(maxWidth: 30, maxHeight: 30)
                        }
                    } else {
                        Image(systemName: ic)
                            .font(.title2)
                            .frame(maxWidth: 30, maxHeight: 30)
                    }
                }
                .buttonStyle(.plain)
                .useDefaultHover({_ in})
            }
            .frame(width: type.iconFrameSize)
        }
    }

    private var ItemLabel: some View {
        ZStack(alignment: .leading) {
            if role != .important {
                role.colour.opacity(0.02)
            } else {
                role.colour
            }

            Text(data)
                .help(help)
                .padding(type.padding)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

extension SidebarItem {
    private func doAction() -> Void {
        if let callback = action {
            callback()
        }
    }

    private func actionOnAppear() -> Void {
        if let ic = icon {
            altIcon = ic + ".fill"
        }
    }
}
