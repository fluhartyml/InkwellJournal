import SwiftUI
import SwiftData

@main
struct InkwellJournalApp: App {
    let container: ModelContainer?

    init() {
        let cloudConfig = ModelConfiguration(cloudKitDatabase: .automatic)
        if let cloudContainer = try? ModelContainer(for: JournalEntry.self, configurations: cloudConfig) {
            print("SwiftData: Using CloudKit-backed container.")
            self.container = cloudContainer
        } else if let localContainer = try? ModelContainer(for: JournalEntry.self) {
            print("SwiftData: CloudKit failed; using local persistent store.")
            self.container = localContainer
        } else if let memoryContainer = try? ModelContainer(for: JournalEntry.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)) {
            print("SwiftData: Both CloudKit and local stores failed; using in-memory store for resilience.")
            self.container = memoryContainer
        } else {
            print("SwiftData: Container initialization failed in all modes.")
            self.container = nil
        }
    }

    var body: some Scene {
        WindowGroup {
            if let container = container {
                ContentView_iOS()
                    .modelContainer(container)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "icloud.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.red)
                    Text("Storage initialization failed")
                        .font(.headline)
                    Text("Check iCloud container provisioning and relaunch the app.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
    }
}
