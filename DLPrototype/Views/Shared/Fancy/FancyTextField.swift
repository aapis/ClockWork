//
//  FancyTextField.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct FancyTextField: View {
    public var placeholder: String
    public var lineLimit: Int
    public var onSubmit: () -> Void
    public var transparent: Bool? = false
    public var disabled: Bool? = false
    
    @Binding public var text: String
    
    @AppStorage("enableAutoCorrection") public var enableAutoCorrection: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            if lineLimit == 1 {
                oneLine
            } else if lineLimit < 9 {
                oneBigLine
            } else {
                multiLine
            }
        }
    }
    
    private var oneLine: some View {
        TextField(placeholder, text: $text)
            .font(Theme.font)
            .textFieldStyle(.plain)
            .disableAutocorrection(enableAutoCorrection)
            .padding()
            .onSubmit(onSubmit)
            .background(transparent! ? Color.clear : Theme.toolbarColour)
            .frame(height: 45)
            .lineLimit(1)
            .disabled(disabled ?? false)
            .foregroundColor(disabled ?? false ? Color.gray : Color.white)
            .textSelection(.enabled)
    }
    
    private var oneBigLine: some View {
        TextField(placeholder, text: $text, axis: .vertical)
            .font(Theme.font)
            .textFieldStyle(.plain)
            .disableAutocorrection(enableAutoCorrection)
            .padding()
            .onSubmit(onSubmit)
            .background(transparent! ? Color.clear : Theme.toolbarColour)
            .lineLimit(lineLimit...)
            .disabled(disabled ?? false)
            .foregroundColor(disabled ?? false ? Color.gray : Color.white)
            .textSelection(.enabled)
    }
    
    private var multiLine: some View {
        TextEditor(text: $text)
            .font(Theme.font)
            .textFieldStyle(.plain)
            .disableAutocorrection(enableAutoCorrection)
            .padding()
            .onSubmit(onSubmit)
            .background(transparent! ? Color.black.opacity(0.1) : Theme.toolbarColour)
            .scrollContentBackground(.hidden)
            .lineLimit(lineLimit...)
            .disabled(disabled ?? false)
            .foregroundColor(disabled ?? false ? Color.gray : Color.white)
            .textSelection(.enabled)
    }
}

struct FancyTextFieldPreview: PreviewProvider {
    @State static private var text: String = "Test text"
    
    static var previews: some View {
        VStack {
            FancyTextField(placeholder: "Small one", lineLimit: 1, onSubmit: {}, text: $text)
            FancyTextField(placeholder: "Medium one", lineLimit: 9, onSubmit: {}, text: $text)
            FancyTextField(placeholder: "Big one", lineLimit: 100, onSubmit: {}, text: $text)
        }
    }
}