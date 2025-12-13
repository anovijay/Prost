//
//  ContentView.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ReadingDashboardView()
                .tabItem {
                    Label("Reading", systemImage: "book.fill")
                }
            
            PlaceholderTabView(title: "Listening")
                .tabItem {
                    Label("Listening", systemImage: "headphones")
                }
            
            PlaceholderTabView(title: "Sprechen")
                .tabItem {
                    Label("Sprechen", systemImage: "waveform")
                }
            
            PlaceholderTabView(title: "Writing")
                .tabItem {
                    Label("Writing", systemImage: "pencil")
                }
        }
    }
}

#Preview {
    ContentView()
}
