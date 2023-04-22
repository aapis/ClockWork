//
//  FancySubTitle.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-14.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct FancySubTitle: View {
    public var text: String
    public var image: String?
    public var showLabel: Bool? = true
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            if image != nil {
                Text(Image(systemName: image!))
                    .font(Theme.fontSubTitle)
            }
            
            if showLabel! {
                Text(text)
                    .font(Theme.fontSubTitle)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
