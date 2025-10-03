//2025 SEP 28 - 1532 - (MLF) InkwellJournalApp.swift Clean Working
import SwiftUI
import SwiftData

@main
struct InkwellJournalApp: App {
    let container: ModelContainer?

    init() {
        // CloudKit-compatible SwiftData setup with default values
        do {
            self.container = try ModelContainer(for: JournalEntry.self)
            print("✅ SwiftData: CloudKit-compatible container initialized")
        } catch {
            print("❌ SwiftData failed: \(error)")
            self.container = nil
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if let container = container {
                ContentView()
                    .modelContainer(container)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 64))
                        .foregroundColor(.orange)
                    Text("Storage Unavailable")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Please restart the app. If the problem persists, check device storage.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .padding()
            }
        }
    }
}

