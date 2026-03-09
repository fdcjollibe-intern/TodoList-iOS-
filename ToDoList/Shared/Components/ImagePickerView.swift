//
//  ImagePickerView.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//

import SwiftUI
import PhotosUI

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard let provider = results.first?.itemProvider else {
                print("⚠️ No item provider available")
                return
            }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                print("📸 Loading image from picker...")
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("❌ Error loading image: \(error.localizedDescription)")
                            return
                        }
                        if let uiImage = image as? UIImage {
                            print("✅ Image loaded successfully: \(uiImage.size)")
                            self.parent.image = uiImage
                        } else {
                            print("❌ Failed to cast image to UIImage")
                        }
                    }
                }
            } else {
                print("⚠️ Provider cannot load UIImage")
            }
        }
    }
}

// MARK: - Image Cropper View

struct ImageCropperView: View {
    @Binding var image: UIImage?
    @Binding var croppedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                    .font(Typography.bodyMedium)
                    
                    Spacer()
                    
                    Text("Crop Photo")
                        .font(Typography.title3)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button("Upload") {
                        cropImage()
                    }
                    .foregroundStyle(Color.appPrimary)
                    .font(Typography.bodySemibold)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.xl)
                
                Spacer()
                
                // Crop Area
                ZStack {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let delta = value / lastScale
                                        lastScale = value
                                        scale *= delta
                                    }
                                    .onEnded { _ in
                                        lastScale = 1.0
                                    }
                            )
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                    }
                    
                    // Crop Circle Overlay
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 2)
                        .frame(width: 250, height: 250)
                        .allowsHitTesting(false)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer()
                
                // Instructions
                Text("Pinch to zoom, drag to move")
                    .font(Typography.caption)
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.bottom, Spacing.xl)
            }
        }
    }
    
    private func cropImage() {
        guard let image = image else {
            print("❌ No image to crop")
            return
        }
        
        print("✂️ Cropping image with scale: \(scale), offset: \(offset)")
        
        let outputSize: CGFloat = 500
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: outputSize, height: outputSize))
        
        let croppedImg = renderer.image { context in
            let rect = CGRect(x: 0, y: 0, width: outputSize, height: outputSize)
            UIBezierPath(ovalIn: rect).addClip()
            
            // Calculate the image rect based on scale and offset
            let imageSize = image.size
            let aspectRatio = imageSize.width / imageSize.height
            
            // Base size to fit in the crop circle (250pt visible area, but we render at 500pt)
            let renderScale: CGFloat = 2.0 // 500pt output / 250pt visible
            var drawRect = CGRect.zero
            
            if aspectRatio > 1 {
                // Landscape: fit height, center width
                let height = outputSize
                let width = height * aspectRatio
                drawRect = CGRect(
                    x: -(width - outputSize) / 2,
                    y: 0,
                    width: width,
                    height: height
                )
            } else {
                // Portrait: fit width, center height
                let width = outputSize
                let height = width / aspectRatio
                drawRect = CGRect(
                    x: 0,
                    y: -(height - outputSize) / 2,
                    width: width,
                    height: height
                )
            }
            
            // Apply user's scale and offset transformations
            let centerX = outputSize / 2
            let centerY = outputSize / 2
            
            context.cgContext.translateBy(x: centerX, y: centerY)
            context.cgContext.scaleBy(x: scale, y: scale)
            context.cgContext.translateBy(
                x: -centerX + (offset.width * renderScale),
                y: -centerY + (offset.height * renderScale)
            )
            
            image.draw(in: drawRect)
        }
        
        print("✅ Image cropped successfully")
        croppedImage = croppedImg
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    ImageCropperView(
        image: .constant(UIImage(systemName: "person.circle.fill")),
        croppedImage: .constant(nil)
    )
}
