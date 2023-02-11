//
//  TaskResult.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-11.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct TaskResult: View {
    public var bucket: FetchedResults<LogTask>
    @Binding public var text: String
    @Binding public var isLoading: Bool
    
    public let maxPerPage: Int = 100
    
    @State private var page: Int = 1
    @State private var numPages: Int = 1
    @State private var offset: Int = 0
    @State private var showChildren: Bool = false
    @State private var minimizeIcon: String = "arrowtriangle.down"
    
    var body: some View {
        GridRow {
            ZStack(alignment: .leading) {
                Theme.subHeaderColour
                
                HStack {
                    Text("\(bucket.count) Tasks")
                        
                    Spacer()
                    FancyButton(text: "Open", action: minimize, icon: minimizeIcon, transparent: true, showLabel: false)
                }
                .padding([.leading, .trailing], 10)
            }
        }
        .frame(height: 40)
        .onChange(of: text) { _ in
            isLoading = true
            showChildren = false
            numPages = 1
            
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { timer in
                if bucket.count > 0 {
                    isLoading = false
                    showChildren = true
                } else {
                    minimize()
                }
            }
        }
        
        if bucket.count > 0 && showChildren {
            GridRow {
                ZStack {
                    Theme.rowColour
                    
                    ScrollView {
                        VStack(spacing: 1) {
                            ForEach(0..<bucket.count) { i in
                                if i <= bucket.count {
                                    let item = bucket[i + offset]
                                    
                                    TaskView(task: item, showJobId: true, showCreated: true, showUpdated: true, showCompleted: true, colourizeRow: true)
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: 300)
        } else {
            if isLoading {
                loading
            }
            
            Divider()
                .foregroundColor(Theme.darkBtnColour)
        }
        
        GridRow {
            ZStack(alignment: .leading) {
                Theme.subHeaderColour
                    
                if bucket.count > 0 && numPages > 1 {
                    HStack(spacing: 1) {
                        ForEach(0..<numPages) { i in
                            FancyButton(text: String(i + 1), action: {showPage(i)}, transparent: true, showIcon: false)
                                .background(page == (i + 1) ? Theme.headerColour : Theme.darkBtnColour)
                        }
                    }
                    .padding([.leading, .trailing], 10)
                }
            }
        }
        .frame(height: 40)
        
        FancyDivider()
    }
    
    @ViewBuilder
    var loading: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                ProgressView("Searching...")
                Spacer()
            }
            .padding([.top, .bottom], 20)
        }.onDisappear(perform: setNumPages)
    }
    
    private func minimize() -> Void {
        withAnimation(.easeInOut) {
            showChildren.toggle()
        }
        
        if showChildren {
            minimizeIcon = "arrowtriangle.down"
        } else {
            minimizeIcon = "arrowtriangle.up"
        }
    }
    
    private func setNumPages() -> Void {
        numPages = 1
        page = 1
        
        if bucket.count > 1 {
            let newNumPages = bucket.count/maxPerPage
            
            if newNumPages > numPages {
                numPages = newNumPages
            }
        }
    }
    
    private func showPage(_ index: Int) -> Void {
        page = (index + 1)
        offset = index * maxPerPage
    }
}
