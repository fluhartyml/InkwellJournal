import SwiftUI
import SwiftData

@main
struct InkwellJournalApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView_iOS()
        }
        // SwiftData model container; with iCloud capability on, this syncs via CloudKit
        .modelContainer(for: JournalEntry.self)
    }
}
