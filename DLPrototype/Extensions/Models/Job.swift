//
//  Job.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

extension Job {
    var idInt: Int { Int(exactly: jid.rounded(.toNearestOrEven)) ?? 0 }

    var backgroundColor: Color {
        if let c = colour {
            return Color.fromStored(c)
        }

        return Color.clear
    }

    var foregroundColor: Color { self.backgroundColor.isBright() ? .black : .white }

    // @TODO: the following are dupes and should be deprecated then removed
    func id_int() -> Int {
        return Int(exactly: jid.rounded(.toNearestOrEven)) ?? 0
    }

    // @TODO: this seems to return a much lighter shade of the actual colour, fix that
    func colour_from_stored() -> Color {
        if let c = colour {
            return Color.fromStored(c)
        }

        return Color.clear
    }

    func fgColour() -> Color {
        return self.colour_from_stored().isBright() ? .black : .white
    }
}
