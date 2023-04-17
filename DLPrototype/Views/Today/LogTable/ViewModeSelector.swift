//
//  ViewModeSelector.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-16.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

public enum ViewMode: Hashable {
    case full, plain
}

public struct ViewModeSelector: View {
    @Binding public var mode: ViewMode
    
    @AppStorage("today.viewMode") public var index: Int = 1
    
    private var items: [CustomPickerItem] {
        return [
            CustomPickerItem(title: "View mode", tag: 0),
            CustomPickerItem(title: "Full", tag: 1),
            CustomPickerItem(title: "Plain", tag: 2)
        ]
    }
    
    public var body: some View {
        FancyPicker(onChange: change, items: items)
            .onAppear(perform: {change(selected: index, sender: "")})
            .onChange(of: index) { _ in
                change(selected: index, sender: "")
            }
    }
    
    private func change(selected: Int, sender: String?) -> Void {
        if selected == 1 || selected == 0 {
            mode = .full
        } else if selected == 2 {
            mode = .plain
        }
        
        index = selected
    }
}