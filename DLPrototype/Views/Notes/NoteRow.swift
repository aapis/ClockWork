//
//  NoteRow.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-11.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct NoteRow: View {
    public var note: Note
    
    var body: some View {
        GridRow {
            HStack(spacing: 1) {
                nProject(note)
                nNote(note)
                nStar(note)
                nVersions(note)
                nAlive(note)
            }
        }
    }
    
    @ViewBuilder private func nProject(_ note: Note) -> some View {
        Group {
            HStack(spacing: 0) {
                ZStack(alignment: .leading) {
                    if note.mJob != nil {
                        Color.fromStored(note.mJob!.project!.colour ?? Theme.rowColourAsDouble)
                    } else {
                        Theme.rowColour
                    }
                }
            }
        }
        .frame(width: 5)
    }
    
    @ViewBuilder private func nNote(_ note: Note) -> some View {
        Group {
            ZStack(alignment: .leading) {
                if note.mJob != nil {
                    Color.fromStored(note.mJob!.colour ?? Theme.rowColourAsDouble)
                } else {
                    Theme.rowColour
                }
                
                FancyTextLink(text: note.title!, destination: AnyView(NoteView(note: note)), fgColour: (note.mJob != nil ? (Color.fromStored(note.mJob!.colour ?? Theme.rowColourAsDouble).isBright() ? Color.black : Color.white)  : Color.white))
            }
        }
    }
    
    @ViewBuilder private func nStar(_ note: Note) -> some View {
        Group {
            ZStack {
                if note.mJob != nil {
                    Color.fromStored(note.mJob!.colour ?? Theme.rowColourAsDouble)
                } else {
                    Theme.rowColour
                }

                if note.starred {
                    Image(systemName: "star.fill")
                        .padding()
                        .foregroundColor(note.mJob != nil ? (Color.fromStored(note.mJob!.colour ?? Theme.rowColourAsDouble).isBright() ? Color.black : Color.white)  : Color.white)
                }
            }
        }
        .frame(width: 100)
    }
    
    @ViewBuilder private func nVersions(_ note: Note) -> some View {
        Group {
            ZStack {
                if note.mJob != nil {
                    Color.fromStored(note.mJob!.colour ?? Theme.rowColourAsDouble)
                } else {
                    Theme.rowColour
                }
                
                Text("\(note.versions!.count)")
                    .padding()
                    .foregroundColor(note.mJob != nil ? (Color.fromStored(note.mJob!.colour ?? Theme.rowColourAsDouble).isBright() ? Color.black : Color.white)  : Color.white)
            }
        }
        .frame(width: 100)
    }
    
    @ViewBuilder private func nAlive(_ note: Note) -> some View {
        Group {
            ZStack {
                (note.alive ? Theme.rowStatusGreen : Color.red.opacity(0.2))
            }
        }
        .frame(width: 5)
    }
}