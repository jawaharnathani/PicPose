//
//  UploadPageView.swift
//  PicPose
//
//  Created by Jawahar Nathani on 22/04/25.
//

import SwiftUI
import PhotosUI

struct UploadPageView: View {
    @State private var userSelectedItem: PhotosPickerItem? = nil
    @State private var locationSelectedItem: PhotosPickerItem? = nil
    @State private var userImage: Image? = nil
    @State private var locationImage: Image? = nil
    @State private var showUserPhotoPicker = false
    @State private var showLocationPhotoPicker = false
    @State private var showUserCamera = false
    @State private var showLocationCamera = false
    @State private var userInputImage: UIImage?
    @State private var locationInputImage: UIImage?
    @State private var selectedGroupType = "Select group type"
    @State private var navigateToPosesView = false
    @State private var energyLevel: Double = 5
    @State private var deckCounter: Int = 0
    @State private var isLoading: Bool = false
    
    @State private var metadata: [String] = []
    @State private var recommendedImages: [ProfileCardModel] = []

    let placeTitle: String

    var body: some View {
        if (isLoading){
            LoadingView()
        } else {
            VStack(spacing: 20) {
                headerSection
                
                VStack {
                    ScrollView {
                        yourPhotoSection
                        
                        if placeTitle == "disneyland" {
                            yourLocationSection
                        }
                        
                        energyLevelSection
                    }
                    .onAppear {
                        setupDeckCounter()
                    }
                    
                    continueButton
                }
                .background(Color.black)
            }
            .navigationDestination(isPresented: $navigateToPosesView) {
                FilledLoadingView(metadata: metadata, recommendedImages: recommendedImages)
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        HStack {
            VStack {
                Text("Upload Images")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text("to get poses from \(placeTitle)")
                    .font(.subheadline)
                    .foregroundColor(Color.black.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }

    private var yourPhotoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Your Photo")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .foregroundColor(Color.white)
                Spacer()
            }
            photoUploadArea(image: userImage, showPicker: $showUserPhotoPicker, showCamera: $showUserCamera) {
                Button("Choose from Photos") {
                    showUserPhotoPicker = true
                }
                Button("Take Photo") {
                    showUserCamera = true
                }
            }
            .photosPicker(isPresented: $showUserPhotoPicker, selection: $userSelectedItem, matching: .images)
            .onChange(of: userSelectedItem) {
                Task {
                    if let data = try? await userSelectedItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        userInputImage = uiImage
                        userImage = Image(uiImage: uiImage)
                    }
                }
            }
            .sheet(isPresented: $showUserCamera) {
                ImageCaptureView { image in
                    if let image = image {
                        userInputImage = image
                        userImage = Image(uiImage: image)
                    }
                }
            }
        }
    }

    private var yourLocationSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Your Location")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .foregroundColor(Color.white)
                Spacer()
            }
            photoUploadArea(image: locationImage, showPicker: $showLocationPhotoPicker, showCamera: $showLocationCamera) {
                Button("Choose from Photos") {
                    showLocationPhotoPicker = true
                }
                Button("Take Photo") {
                    showLocationCamera = true
                }
            }
            .photosPicker(isPresented: $showLocationPhotoPicker, selection: $locationSelectedItem, matching: .images)
            .onChange(of: locationSelectedItem) {
                Task {
                    if let data = try? await locationSelectedItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        locationInputImage = uiImage
                        locationImage = Image(uiImage: uiImage)
                    }
                }
            }
            .sheet(isPresented: $showLocationCamera) {
                ImageCaptureView { image in
                    if let image = image {
                        locationInputImage = image
                        locationImage = Image(uiImage: image)
                    }
                }
            }
        }
    }

    private func photoUploadArea<Content: View>(
        image: Image?,
        showPicker: Binding<Bool>,
        showCamera: Binding<Bool>,
        @ViewBuilder buttons: () -> Content
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.white, lineWidth: 1)
                .frame(height: 180)
                .background(
                    Group {
                        if let image = image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .clipped()
                                .cornerRadius(12)
                        } else {
                            Color.gray
                                .cornerRadius(12)
                        }
                    }
                )
            if image == nil {
                VStack(spacing: 10) {
                    buttons()
                        .font(.body.bold())
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.85))
                        .cornerRadius(8)
                        .shadow(radius: 1)
                }
            }
        }
        .padding(.horizontal)
    }

    private var energyLevelSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Energy Level")
                .font(.headline)
                .foregroundColor(.white)

            HStack {
                Slider(value: $energyLevel, in: 1...10, step: 1)
                    .accentColor(.blue)
                Text("\(Int(energyLevel))")
                    .frame(width: 30)
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
        .padding(.vertical, 20)
    }

    private var continueButton: some View {
        Button(action: {
            Task {
                await sendImagesToServer()
            }
        }) {
            Text("Find Pose")
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding()
        .background(Color.black)
    }

    // MARK: - Helpers

    private func setupDeckCounter() {
        if placeTitle == "Eiffel Tower" {
            deckCounter = 1
        } else if placeTitle == "disneyland" {
            deckCounter = 2
        } else {
            deckCounter = 3
        }
    }
    
    private struct ServerResponse: Codable {
        let metadata: [String]
        let images: [ServerImage]
    }

    private struct ServerImage: Codable {
        let id: String
        let caption: String
        let data: String
    }

    private func createMultipartBody(userImage: UIImage, locationImage: UIImage?, placeTitle: String, energyLevel: Double, boundary: String) async throws -> Data {
        var body = Data()

        func addStringPart(fieldName: String, value: String) {
            let boundaryPrefix = "--\(boundary)\r\n"
            let contentDisposition = "Content-Disposition: form-data; name=\"\(fieldName)\"\r\n\r\n"
            body.append(Data(boundaryPrefix.utf8))
            body.append(Data(contentDisposition.utf8))
            body.append(Data(value.utf8))
            body.append(Data("\r\n".utf8))
        }

        func addImagePart(fieldName: String, image: UIImage, filename: String) {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                let boundaryPrefix = "--\(boundary)\r\n"
                let contentDisposition = "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(filename)\"\r\n"
                let contentType = "Content-Type: image/jpeg\r\n\r\n"

                body.append(Data(boundaryPrefix.utf8))
                body.append(Data(contentDisposition.utf8))
                body.append(Data(contentType.utf8))
                body.append(imageData)
                body.append(Data("\r\n".utf8))
            }
        }

        // First, add the string
        addStringPart(fieldName: "place_title", value: placeTitle)
        addStringPart(fieldName: "energy_level", value: String(energyLevel))

        // Then, add the images
        addImagePart(fieldName: "user_image", image: userImage, filename: "user.jpg")

        if let locationImage = locationImage {
            addImagePart(fieldName: "location_image", image: locationImage, filename: "location.jpg")
        }

        let closingBoundary = "--\(boundary)--\r\n"
        body.append(Data(closingBoundary.utf8))
        return body
    }

    private func sendImagesToServer() async {
        isLoading = true;
        
        guard let userInputImage = userInputImage else {
            print("User image not selected")
            return
        }

        do {
            guard let url = URL(string: "http://127.0.0.1:5000/process-images") else {
                print("Invalid URL")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            let body = try await createMultipartBody(userImage: userInputImage, locationImage: locationInputImage, placeTitle: placeTitle, energyLevel: energyLevel, boundary: boundary)
            request.httpBody = body

            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Successfully uploaded images")
                
                let decoder = JSONDecoder()
                let serverResponse = try decoder.decode(ServerResponse.self, from: data)

                // Print string fields
                metadata = serverResponse.metadata

                // Print filenames and convert images
                for imageInfo in serverResponse.images {
                    print("Image filename: \(imageInfo.id)")

                    if let imageData = Data(base64Encoded: imageInfo.data),
                       let uiImage = UIImage(data: imageData) {
                        recommendedImages.append(ProfileCardModel(id: imageInfo.id, caption: imageInfo.caption, picture: [uiImage]))
                    } else {
                        print("Failed to decode image: \(imageInfo.id)")
                    }
                }
                
                navigateToPosesView = true
            } else {
                print("Server error: \(response)")
            }
        } catch {
            print("Failed to upload images: \(error)")
        }
        
        isLoading = false
    }
}

// MARK: - Camera View for Taking Photo
struct ImageCaptureView: UIViewControllerRepresentable {
    var completion: (UIImage?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var completion: (UIImage?) -> Void

        init(completion: @escaping (UIImage?) -> Void) {
            self.completion = completion
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as? UIImage
            completion(image)
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            completion(nil)
            picker.dismiss(animated: true)
        }
    }
}

// Preview
#Preview {
    UploadPageView(placeTitle: "WonderLand")
}
