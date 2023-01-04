//
//  GeneralSettingsView.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct GeneralSettings: View {
    @AppStorage("tigerStriped") private var tigerStriped = false
    @AppStorage("defaultTableSortOrder") private var defaultTableSortOrder = "DESC"
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures = false
    @AppStorage("showExperiment.actions") private var showExperimentActions = false

    var body: some View {
        Form {
            Toggle("Tiger stripe table rows", isOn: $tigerStriped)
            
            Group {
                Toggle("Experimental features (may tank performance)", isOn: $showExperimentalFeatures)
                
                if showExperimentalFeatures {
                    Toggle("Show row actions", isOn: $showExperimentActions)
                }
            }
            
            Picker("Default table sort direction:", selection: $defaultTableSortOrder) {
                Text("DESC").tag("DESC")
                Text("ASC").tag("ASC")
            }
        }
        .padding(20)
        .frame(width: 350, height: 100)
    }
}

struct GeneralSettingsPreview: PreviewProvider {
    static var previews: some View {
        GeneralSettings()
    }
}