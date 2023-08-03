//
//  RecentNotesWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct RecentNotesWidget: View {
    public let title: String = "Recent Notes"

    @State private var minimized: Bool = false

    @FetchRequest public var notes: FetchedResults<Note>

    @Environment(\.managedObjectContext) var moc

    public init() {
        _notes = CoreDataNotes.fetchRecentNotes(limit: 7)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                FancySubTitle(text: "\(title)")
                Spacer()
                FancyButtonv2(
                    text: "Minimize",
                    action: {minimized.toggle()},
                    icon: minimized ? "plus" : "minus",
                    showLabel: false,
                    type: .white
                )
                .frame(width: 30, height: 30)
            }

            if !minimized {
                VStack(alignment: .leading, spacing: 5) {
                    if notes.count > 0 {
                        ForEach(notes) { note in
                            NoteRowPlain(note: note, moc: moc)
                        }
                    } else {
                        Text("Create a note first")
                    }
                }
            }
        }
    }
}
