//2025 SEP 28 1529 Clean Workking ContentView.swift
import SwiftUI
import SwiftData
import VisionKit

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
                        Spacer()

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

                        Spacer()
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(entries) { entry in
                            NavigationLink(value: entry) {
                                EntryRowView(entry: entry)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("My Journal")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewEntry = true }) {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
            }
            .navigationDestination(for: JournalEntry.self) { entry in
                EntryDetailView(entry: entry)
            }
        }
        .fullScreenCover(isPresented: $showingNewEntry) {
            NewEntryView()
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
            if let image = entry.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(8)
            }

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
    @State private var editImage: UIImage?
    @State private var showingCameraOptions = false
    @State private var showingImagePicker = false
    @State private var cameraSourceType: UIImagePickerController.SourceType = .camera
    @State private var cameraDevice: UIImagePickerController.CameraDevice = .rear
    @State private var showingDocumentScanner = false

    let moods = ["Happy", "Sad", "Excited", "Calm", "Grateful", "Neutral"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    // --- Mood and Date Row with smaller font and tighter padding ---
                    HStack {
                        Text(isEditing ? editMood : entry.mood)
                            .font(.caption2)                           // Changed from caption to caption2
                            .padding(.horizontal, 8)                   // Reduced horizontal padding
                            .padding(.vertical, 3)                     // Reduced vertical padding
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)                           // Reduced corner radius

                        Spacer()

                        Text(entry.formattedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 12)                           // Added spacing below mood/date row

                    if isEditing {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Title").font(.headline)
                            TextField("Enter a title...", text: $editTitle)
                                .textFieldStyle(.roundedBorder)
                        }

                        VStack(alignment: .leading, spacing: 0) {
                            Text("Mood").font(.headline)
                            Picker("Mood", selection: $editMood) {
                                ForEach(moods, id: \.self) { Text($0).tag($0) }
                            }
                            .pickerStyle(.segmented)
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Photo").font(.headline)
                            if let editImage = editImage {
                                Image(uiImage: editImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                                    .cornerRadius(8)
                            }
                            Button(action: { showingCameraOptions = true }) {
                                HStack {
                                    Image(systemName: "camera")
                                    Text(editImage == nil ? "Add Photo" : "Change Photo")
                                }
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                            }
                            if editImage != nil {
                                Button(action: { editImage = nil }) {
                                    HStack {
                                        Image(systemName: "trash")
                                        Text("Remove Photo")
                                    }
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.red, lineWidth: 1)
                                    )
                                }
                            }
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
                        // --- Non-editing Title with adjusted font and padding ---
                        Text(entry.title)
                            .font(.title3)                                  // Changed from title2 to title3
                            .fontWeight(.medium)                            // Changed from semibold to medium
                            .padding(.top, 8)                               // Added top padding for separation

                        if let image = entry.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .cornerRadius(8)
                        }

                        Text(entry.content)
                            .font(.body)
                            .lineSpacing(0)
                            .padding(.top, 8)                               // Added some spacing below title/image to content
                    }
                }
            }
        }
        .clipped()
        .navigationTitle("Journal Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(.systemBackground), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
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
                    // --- Show only Edit button when not editing ---
                    Button("Edit") { startEditing() }
                }
            }
        }
        .onAppear { resetEditFields() }
        .confirmationDialog("Add Photo", isPresented: $showingCameraOptions) {
            Button("Selfie") {
                cameraSourceType = .camera
                cameraDevice = .front
                showingImagePicker = true
            }
            Button("Landscape Picture") {
                cameraSourceType = .camera
                cameraDevice = .rear
                showingImagePicker = true
            }
            Button("Photos") {
                cameraSourceType = .photoLibrary
                showingImagePicker = true
            }
            Button("Scan Document") {
                showingDocumentScanner = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(
                selectedImage: $editImage,
                sourceType: cameraSourceType,
                cameraDevice: cameraDevice
            )
        }
        .sheet(isPresented: $showingDocumentScanner) {
            DocumentScanner(selectedImage: $editImage)
        }
    }

    private func startEditing() {
        editTitle = entry.title
        editContent = entry.content
        editMood = entry.mood
        editImage = entry.image
        isEditing = true
    }

    private func resetEditFields() {
        editTitle = entry.title
        editContent = entry.content
        editMood = entry.mood
        editImage = entry.image
    }

    private func saveChanges() {
        entry.title = editTitle
        entry.content = editContent
        entry.mood = editMood
        entry.imageData = editImage?.jpegData(compressionQuality: 0.8)
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
    @State private var selectedImage: UIImage?
    @State private var showingCameraOptions = false
    @State private var showingImagePicker = false
    @State private var cameraSourceType: UIImagePickerController.SourceType = .camera
    @State private var cameraDevice: UIImagePickerController.CameraDevice = .rear
    @State private var showingDocumentScanner = false

    @FocusState private var focusedField: Field?
    private enum Field { case title, content }

    let moods = ["Happy", "Sad", "Excited", "Calm", "Grateful", "Neutral"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Enter a title...", text: $title)
                        .textInputAutocapitalization(.sentences)
                        .disableAutocorrection(false)
                        .focused($focusedField, equals: .title)
                }

                Section("Mood") {
                    Picker("Mood", selection: $mood) {
                        ForEach(moods, id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Photo") {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 220)
                            .cornerRadius(8)
                    }
                    Button(action: { showingCameraOptions = true }) {
                        Label(selectedImage == nil ? "Add Photo" : "Change Photo", systemImage: "camera")
                    }
                }

                Section("Your thoughts") {
                    TextEditor(text: $content)
                        .frame(minHeight: 180)
                        .focused($focusedField, equals: .content)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
                        let entry = JournalEntry(
                            title: title,
                            content: content,
                            mood: mood,
                            imageData: imageData
                        )
                        modelContext.insert(entry)
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        .confirmationDialog("Add Photo", isPresented: $showingCameraOptions) {
            Button("Selfie") {
                cameraSourceType = .camera
                cameraDevice = .front
                showingImagePicker = true
            }
            Button("Landscape Picture") {
                cameraSourceType = .camera
                cameraDevice = .rear
                showingImagePicker = true
            }
            Button("Photos") {
                cameraSourceType = .photoLibrary
                showingImagePicker = true
            }
            Button("Scan Document") {
                showingDocumentScanner = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(
                selectedImage: $selectedImage,
                sourceType: cameraSourceType,
                cameraDevice: cameraDevice
            )
        }
        .sheet(isPresented: $showingDocumentScanner) {
            DocumentScanner(selectedImage: $selectedImage)
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    let sourceType: UIImagePickerController.SourceType
    let cameraDevice: UIImagePickerController.CameraDevice
    
    init(selectedImage: Binding<UIImage?>, sourceType: UIImagePickerController.SourceType = .camera, cameraDevice: UIImagePickerController.CameraDevice = .rear) {
        self._selectedImage = selectedImage
        self.sourceType = sourceType
        self.cameraDevice = cameraDevice
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        
        if sourceType == .camera && UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.cameraDevice = cameraDevice
        } else if sourceType == .photoLibrary {
            picker.sourceType = .photoLibrary
        } else {
            // Fallback to photo library if camera not available
            picker.sourceType = .photoLibrary
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Document Scanner
struct DocumentScanner: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: DocumentScanner
        
        init(_ parent: DocumentScanner) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            if scan.pageCount > 0 {
                parent.selectedImage = scan.imageOfPage(at: 0)
            }
            parent.dismiss()
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.dismiss()
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            parent.dismiss()
        }
    }
}

// MARK: - Launch Logo Preview (temporary)
struct LaunchLogoPreviewView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            Image("LaunchLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 220)
                .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 8)
        }
    }
}

#Preview("Launch Logo — Light") {
    LaunchLogoPreviewView()
}

#Preview("Launch Logo — Dark") {
    LaunchLogoPreviewView()
        .environment(\.colorScheme, .dark)
}

