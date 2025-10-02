import SwiftUI
import SwiftData

struct EntryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var entry: JournalEntry
    var isNew: Bool
    var onCancel: (() -> Void)?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Title")) {
                    TextField("Title", text: $entry.title)
                        .textInputAutocapitalization(.sentences)
                }

                Section("Content") {
                    TextEditor(text: $entry.content)
                        .frame(minHeight: 220)
                }

                Section("Mood") {
                    Picker("Mood", selection: $entry.mood) {
                        Text("Neutral").tag("Neutral")
                        Text("Happy").tag("Happy")
                        Text("Sad").tag("Sad")
                        Text("Excited").tag("Excited")
                        Text("Calm").tag("Calm")
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle(isNew ? "New Entry" : "Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        onCancel?()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .bold()
                }
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: JournalEntry.self, configurations: .init(isStoredInMemoryOnly: true))
    let context = ModelContext(container)
    let sample = JournalEntry(title: "Sample", content: "Lorem ipsum dolor sit amet.", mood: "Happy")
    context.insert(sample)
    return EntryEditorView(entry: sample, isNew: false) {}
        .modelContainer(container)
}
