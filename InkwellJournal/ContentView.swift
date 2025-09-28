import SwiftUI
import SwiftData

// MARK: - Root Content
struct ContentView_iOS: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.dateCreated, order: .reverse) private var entries: [JournalEntry]
    @State private var showingNewEntry = false
    @State private var selectedEntry: JournalEntry?

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 64))
                            .foregroundColor(.gray)

                        Text("Start Your Journal")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text("Tap the + button to create your first entry")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(entries) { entry in
                            EntryRowView(entry: entry)
                                .onTapGesture { selectedEntry = entry }
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("My Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewEntry = true }) {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
            }
            .fullScreenCover(isPresented: $showingNewEntry) {
                NewEntryView()
            }
            .sheet(isPresented: Binding(
                get: { selectedEntry != nil },
                set: { if !$0 { selectedEntry = nil } }
            )) {
                if let entry = selectedEntry {
                    EntryDetailView(entry: entry)
                }
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let entry = entries[index]
            modelContext.delete(entry)
        }
        try? modelContext.save()
    }
}

// MARK: - Row
struct EntryRowView: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.mood)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)

                Spacer()

                Text(entry.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(entry.title)
                .font(.headline)

            Text(entry.content)
                .font(.body)
                .lineLimit(3)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Detail
struct EntryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let entry: JournalEntry
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    @State private var editTitle = ""
    @State private var editContent = ""
    @State private var editMood = ""

    let moods = ["Happy", "Sad", "Excited", "Calm", "Grateful", "Neutral"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(isEditing ? editMood : entry.mood)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(12)

                            Spacer()

                            Text(entry.formattedDate)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        if isEditing {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Title").font(.headline)
                                TextField("Enter a title...", text: $editTitle)
                                    .textFieldStyle(.roundedBorder)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Mood").font(.headline)
                                Picker("Mood", selection: $editMood) {
                                    ForEach(moods, id: \.self) { Text($0).tag($0) }
                                }
                                .pickerStyle(.segmented)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Your thoughts").font(.headline)
                                TextEditor(text: $editContent)
                                    .frame(minHeight: 200)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        } else {
                            Text(entry.title)
                                .font(.title2)
                                .fontWeight(.semibold)

                            Text(entry.content)
                                .font(.body)
                                .lineSpacing(4)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Journal Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if isEditing {
                        Button("Cancel") {
                            isEditing = false
                            resetEditFields()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing {
                        Button("Save") {
                            saveChanges()
                            isEditing = false
                        }
                        .disabled(editTitle.isEmpty)
                    } else {
                        HStack {
                            Button("Edit") { startEditing() }
                            Button("Done") { dismiss() }
                        }
                    }
                }
            }
        }
        .onAppear { resetEditFields() }
    }

    private func startEditing() {
        editTitle = entry.title
        editContent = entry.content
        editMood = entry.mood
        isEditing = true
    }

    private func resetEditFields() {
        editTitle = entry.title
        editContent = entry.content
        editMood = entry.mood
    }

    private func saveChanges() {
        entry.title = editTitle
        entry.content = editContent
        entry.mood = editMood
        try? modelContext.save()
    }
}

// MARK: - New Entry
struct NewEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var content = ""
    @State private var mood = "Happy"

    let moods = ["Happy", "Sad", "Excited", "Calm", "Grateful", "Neutral"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title").font(.headline)
                        TextField("Enter a title...", text: $title)
                            .textFieldStyle(.roundedBorder)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mood").font(.headline)
                        Picker("Mood", selection: $mood) {
                            ForEach(moods, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.segmented)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your thoughts").font(.headline)
                        TextEditor(text: $content)
                            .frame(minHeight: 200)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                .padding()
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let entry = JournalEntry(
                            title: title,
                            content: content,
                            mood: mood
                        )
                        modelContext.insert(entry)
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
