//
//  Dashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct Dashboard: View {
    @EnvironmentObject public var crm: CoreDataRecords
    
    var body: some View {
        VStack(spacing: 0) {
            Widgets().environmentObject(crm)
            
            // TODO: do we need to render find here?
            FindDashboard()
        }
    }
}
