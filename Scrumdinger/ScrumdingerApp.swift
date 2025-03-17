//
//  ScrumdingerApp.swift
//  Scrumdinger
//
//  Created by Auwfar on 14/03/25.
//

import SwiftUI

@main
struct ScrumdingerApp: App {
    @State private var scrums = DailyScrum.sampleData
    
    var body: some Scene {
        WindowGroup {
            ScrumsView(scrums: $scrums)
        }
    }
}
