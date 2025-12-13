//
//  ProstApp.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import SwiftUI

@main
struct ProstApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
