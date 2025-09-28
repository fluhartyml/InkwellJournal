import SwiftUI
import SwiftData

@main
struct InkwellJournalApp: App {
    let container: ModelContainer

    init() {
        do {
            // Create schema with proper versioning
            let schema = Schema([JournalEntry.self])
            
            // First try local configuration to avoid CloudKit issues during development
            let localConfig = ModelConfiguration(
                "JournalEntries",
                schema: schema
            )
            
            self.container = try ModelContainer(for: schema, configurations: [localConfig])
            print("✅ SwiftData: Successfully initialized local container")
            
        } catch {
            print("❌ SwiftData initialization error: \(error)")
            
            // Last resort: in-memory container
            do {
                let schema = Schema([JournalEntry.self])
                let memoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                self.container = try ModelContainer(for: schema, configurations: [memoryConfig])
                print("⚠️ SwiftData: Using in-memory storage as fallback")
            } catch {
                fatalError("Failed to create SwiftData container: \(error)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView_iOS()
                .modelContainer(container)
        }
    }
}
