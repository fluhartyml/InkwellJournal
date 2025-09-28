// InkwellJournal – iOS ContentView (SwiftData + CloudKit)
// Replace your existing ContentView_iOS.swift with this file.

#if os(iOS) || targetEnvironment(macCatalyst)

import SwiftUI
import SwiftData
import PhotosUI
#if canImport(VisionKit)
import VisionKit
#endif
import UIKit
import AVFoundation
import Foundation




























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

                        Text("Add photos to capture visual memories")
                            .font(.caption)
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
        HStack {
            if let image = entry.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(entry.mood)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(entry.formattedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if entry.modifiedAt != entry.dateCreated {
                            Text("Modified")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Text(entry.title)
                    .font(.headline)

                Text(entry.content)
                    .font(.body)
                    .lineLimit(3)
                    .foregroundColor(.secondary)
            }

            Spacer()
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
    @State private var selectedImage: UIImage?
    @State private var imageChanged = false

    let moods = ["Happy", "Sad", "Excited", "Calm", "Grateful", "Neutral"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let image = (isEditing ? selectedImage : entry.image) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(isEditing ? editMood : entry.mood)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(12)

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text(entry.formattedDate)
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                if entry.modifiedAt != entry.dateCreated {
                                    Text("Modified \(entry.modifiedAt, style: .relative) ago")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
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
        selectedImage = entry.image
        imageChanged = false
        isEditing = true
    }

    private func resetEditFields() {
        editTitle = entry.title
        editContent = entry.content
        editMood = entry.mood
        selectedImage = entry.image
        imageChanged = false
    }

    private func saveChanges() {
        entry.title = editTitle
        entry.content = editContent
        entry.mood = editMood
        entry.modifiedAt = Date()
        if imageChanged {
            entry.imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        }
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

    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingDocumentScanner = false
    @State private var showingPhotoOptions = false
    @State private var cameraPosition: CameraPosition = .back

    let moods = ["Happy", "Sad", "Excited", "Calm", "Grateful", "Neutral"]

    private func ensureCameraAvailableAndAuthorized(_ completion: @escaping (Bool) -> Void) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            completion(false); return
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        default:
            completion(false)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Image
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Photo").font(.headline)

                        if let selectedImage {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 200)
                                    .cornerRadius(12)

                                Button(action: { self.selectedImage = nil }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
                                .padding(8)
                            }
                        } else {
                            Button(action: {
#if targetEnvironment(simulator)
                                showingImagePicker = true
#else
                                showingPhotoOptions = true
#endif
                            }) {
                                VStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.title)
                                        .foregroundColor(.blue)
                                    Text("Add Photo")
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                    Text("Selfie • Landscape • Document")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, minHeight: 120)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }

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
                        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
                        let entry = JournalEntry(
                            title: title,
                            content: content,
                            date: Date(),
                            mood: mood,
                            imageData: imageData
                        )
                        modelContext.insert(entry)
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .confirmationDialog("Add Photo", isPresented: $showingPhotoOptions) {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Take Selfie") {
                        ensureCameraAvailableAndAuthorized { ok in
                            if ok { cameraPosition = .front; showingCamera = true }
                        }
                    }
                    Button("Take Photo") {
                        ensureCameraAvailableAndAuthorized { ok in
                            if ok { cameraPosition = .back; showingCamera = true }
                        }
                    }
                }
#if canImport(VisionKit)
                if VNDocumentCameraViewController.isSupported {
                    Button("Scan Document") { showingDocumentScanner = true }
                }
#endif
                Button("Choose from Library") { showingImagePicker = true }
                Button("Cancel", role: .cancel) { }
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView(selectedImage: $selectedImage, cameraPosition: cameraPosition)
            }
            .sheet(isPresented: $showingImagePicker) {
                PhotoPickerView(selectedImage: $selectedImage)
            }
#if canImport(VisionKit)
            .sheet(isPresented: $showingDocumentScanner) {
                DocumentScannerView(selectedImage: $selectedImage)
            }
#endif
        }
    }
}

// MARK: - Camera / Photo Picker / Doc Scanner (unchanged logic)

enum CameraPosition { case front, back }

struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    let cameraPosition: CameraPosition
    var onImageSelected: (() -> Void)? = nil

    typealias Context = UIViewControllerRepresentableContext<CameraView>

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.cameraDevice = cameraPosition == .front ? .front : .rear
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        init(_ parent: CameraView) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.onImageSelected?()
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct PhotoPickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    var onImageSelected: (() -> Void)? = nil

    typealias Context = UIViewControllerRepresentableContext<PhotoPickerView>

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerView
        init(_ parent: PhotoPickerView) { self.parent = parent }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider else { return }
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                        self.parent.onImageSelected?()
                    }
                }
            }
        }
    }
}

#if canImport(VisionKit)
struct DocumentScannerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    var onImageSelected: (() -> Void)? = nil

    typealias Context = UIViewControllerRepresentableContext<DocumentScannerView>

    func makeUIViewController(context: Context) -> UIViewController {
        if VNDocumentCameraViewController.isSupported {
            let scanner = VNDocumentCameraViewController()
            scanner.delegate = context.coordinator
            return scanner
        } else {
            let vc = UIViewController()
            DispatchQueue.main.async { self.dismiss() }
            return vc
        }
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: DocumentScannerView
        init(_ parent: DocumentScannerView) { self.parent = parent }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFinishWith scan: VNDocumentCameraScan) {
            if scan.pageCount > 0 {
                parent.selectedImage = scan.imageOfPage(at: 0)
                parent.onImageSelected?()
            }
            parent.dismiss()
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFailWithError error: Error) {
            parent.dismiss()
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.dismiss()
        }
    }
}
#endif

#Preview {
    ContentView_iOS()
}

#endif // os(iOS) || targetEnvironment(macCatalyst)

