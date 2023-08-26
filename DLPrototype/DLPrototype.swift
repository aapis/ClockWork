//
//  AppDelegate.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-09.
//  Copyright © 2020 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

@main
struct DLPrototype: App {
    private let persistenceController = PersistenceController.shared
    @StateObject public var updater: ViewUpdater = ViewUpdater()
    @StateObject public var nav: Navigation = Navigation()
    @StateObject public var ce: CoreDataCalendarEvent = CoreDataCalendarEvent(moc: PersistenceController.shared.container.viewContext)
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            Home()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(updater)
                .environmentObject(nav)
                .environmentObject(ce)
                .onAppear(perform: onAppear)
                .onChange(of: scenePhase) { _ in
                    persistenceController.save()
                }
        }
        // TODO: still shows the window close/minimize/zoom,
        // see https://stackoverflow.com/questions/70501890/how-can-i-hide-title-bar-in-swiftui-for-macos-app
//        .windowStyle(.hiddenTitleBar)
        // TODO: need to define the commands we want to implement
        .commands {
            MainMenu(moc: persistenceController.container.viewContext, nav: nav)
        }

        #if os(macOS)
        Settings {
            SettingsView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(ce)
                .environmentObject(nav)
        }
        
        // TODO: temp commented out, too early to include this
//        MenuBarExtra("name", systemImage: "keyboard.macwindow") {
//            Button("Quick Record") {
//                print("TODO: implement quick record")
//            }.keyboardShortcut("1")
//            Button("Quick Search") {
//                print("TODO: implement quick search")
//            }.keyboardShortcut("2")
//
//            Divider()
//            Button("Quit") {
//                NSApplication.shared.terminate(nil)
//            }.keyboardShortcut("q")
//        }
        #endif
    }

    private func onAppear() -> Void {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
        
        // https://github.com/lukakerr/NSWindowStyles
//        NSApp?.mainWindow?.styleMask.remove(.titled)
//        NSApp.presentationOptions.remove(.titled)

        nav.title = "\(appName ?? "DLPrototype") \(version ?? "0").\(build ?? "0")"
        nav.session.plan = CoreDataPlan(moc: persistenceController.container.viewContext).forToday().first

        if let plan = nav.session.plan {
            nav.planning.jobs = plan.jobs as! Set<Job>
            nav.planning.tasks = plan.tasks as! Set<LogTask>
            nav.planning.notes = plan.notes as! Set<Note>
            nav.planning.id = plan.id!
        }
    }
}
