import SwiftUI
import PhotosUI
import UIKit

struct ReceiptScannerView: View {
    @Binding var receiptImageData: Data?
    @Binding var receiptFileName: String?
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var capturedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 20) {
            if let imageData = receiptImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                
                if let fileName = receiptFileName {
                    Text(fileName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Button("Remove Receipt") {
                    receiptImageData = nil
                    receiptFileName = nil
                }
                .buttonStyle(.bordered)
                .foregroundStyle(.red)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.viewfinder")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text("Add Receipt")
                        .font(.headline)
                    
                    Text("Scan or take a photo of your service receipt")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            
            HStack(spacing: 16) {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("Photo Library", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button {
                    showingCamera = true
                } label: {
                    Label("Camera", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .onChange(of: selectedItem) {
            Task {
                guard let newItem = selectedItem else { return }
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    receiptImageData = data
                    receiptFileName = "Receipt_\(Date().formatted(date: .numeric, time: .omitted)).jpg"
                }
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(capturedImage: $capturedImage)
        }
        .onChange(of: capturedImage) {
            if let image = capturedImage,
               let data = image.jpegData(compressionQuality: 0.8) {
                receiptImageData = data
                receiptFileName = "Receipt_\(Date().formatted(date: .numeric, time: .omitted)).jpg"
            }
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.capturedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    ReceiptScannerView(receiptImageData: .constant(nil), receiptFileName: .constant(nil))
}

