//
//  ScrumdingerApp.swift
//  Scrumdinger
//
//  Created by Auwfar on 14/03/25.
//

import SwiftUI

@main
struct ScrumdingerApp: App {
    var body: some Scene {
        WindowGroup {
            ScrumsView(scrums: DailyScrum.sampleData)
        }
    }
}
