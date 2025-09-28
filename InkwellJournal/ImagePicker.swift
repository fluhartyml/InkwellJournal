import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    enum SourceType {
        case camera
        case photoLibrary
    }
    
    let sourceType: SourceType
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        
        switch sourceType {
        case .camera:
            picker.sourceType = .camera
            picker.cameraDevice = .front // Default to front camera for selfies
        case .photoLibrary:
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
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
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

struct PhotoActionSheet: View {
    @Binding var showingImagePicker: Bool
    @Binding var imagePickerSource: ImagePicker.SourceType
    @Binding var selectedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                imagePickerSource = .camera
                showingImagePicker = true
            }) {
                HStack {
                    Image(systemName: "camera.fill")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    Text("Take Photo")
                        .font(.body)
                    Spacer()
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
            }
            
            Divider()
            
            Button(action: {
                imagePickerSource = .photoLibrary  
                showingImagePicker = true
            }) {
                HStack {
                    Image(systemName: "photo.fill")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    Text("Choose from Library")
                        .font(.body)
                    Spacer()
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
            }
            
            if selectedImage != nil {
                Divider()
                
                Button(action: {
                    selectedImage = nil
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        Text("Remove Photo")
                            .font(.body)
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                }
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .padding()
    }
}