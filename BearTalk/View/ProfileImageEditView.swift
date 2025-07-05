//
//  ProfileImageEditView.swift
//  Alma
//
//  Created by Joe Cieplinski on 1/11/25.
//

import SwiftUI

struct ProfileImageEditView: View {
    @Environment(DataModel.self) var model
    @Environment(\.dismiss) var dismiss
    
    var viewModel: ProfileImageEditViewModel
    
    @State private var isImagePickerPresented: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
        NavigationStack {
                ZStack {
                    if viewModel.inputImage.size != .zero {
                        ZStack {
                            self.imageView
                                .scaleEffect(viewModel.scale)
                                .offset(viewModel.offset)
                                .animation(.spring(duration: 0.3), value: viewModel.scale)
                                .clipped()
                            
                            CircleCutOut(size: viewModel.cropSize)
                                .fill(
                                    .ultraThinMaterial,
                                    style: FillStyle(eoFill: true, antialiased: true)
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .allowsHitTesting(false)
                            
                            Circle()
                                .foregroundColor(Color.clear)
                                .frame(
                                    width: viewModel.cropSize.width,
                                    height: viewModel.cropSize.height
                                )
                                .background(
                                    Circle()
                                        .stroke(Color.white,lineWidth: 2)
                                )
                        }
                        .overlay(alignment: .top) {
                            Circle()
                                .frame(height: 10)
                                .foregroundStyle(.thinMaterial.opacity(0.5))
                                .offset(y: -10)
                        }
                        
                        VStack {
                            Text("Drag and zoom the image until the portion within the circle looks just right.")
                                .padding(.top, 16)
                            
                            Spacer()
                        }
                        .padding()
                        .safeAreaInset(edge: .bottom) {
                            VStack(spacing: 22) {
                                Button {
                                    isImagePickerPresented = true
                                    viewModel.reset()
                                } label: {
                                    Label("Change Photo", systemImage: "photo.artframe")
                                        .padding(4)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .tint(.accentColor)
                                .padding(.top, 44)
                                
                                Button {
                                    Task {
                                        try await viewModel.finish()
                                        
                                        dismiss()
                                    }
                                } label: {
                                    Label("Set Profile Image", systemImage: "checkmark")
                                        .padding(4)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.secondary)
                                .padding(.bottom, 66)
                                .disabled(viewModel.isWorking)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                        }
                    } else {
                        VStack {
                            Button {
                                isImagePickerPresented = true
                            } label: {
                                HStack(spacing: 4) {
                                    Text("Select Image")
                                    
                                    Image(systemName: "photo.artframe")
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    if viewModel.isWorking {
                        ProgressView()
                            .controlSize(.large)
                    }
                }
                .onAppear {
                    viewModel.proxySize = proxy.size
                }
                .background(.ultraThinMaterial)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        if #available(iOS 26.0, *) {
                            Button(role: .confirm) {
                                dismiss()
                            }
                            .tint(.active)
                        } else {
                            Button {
                                dismiss()
                            } label: {
                                Label("Done", systemImage: "xmark.circle.fill")
                                    .labelStyle(.titleOnly)
                            }
                        }
                    }
                }
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePickerView(imagePicker: viewModel.imagePicker) { image in
                        viewModel.imageCaptured(image)
                    }
                }
            }
            .ignoresSafeArea(edges: [.bottom])
        }
    }
    
    var imageView: some View {
        Group {
            if viewModel.inputImage.size != .zero {
                Image(uiImage: viewModel.inputImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .gesture(MagnifyGesture()
                        .onChanged { value in
                            viewModel.currentZoom = (value.magnification - 1) / 10
                            viewModel.setOffset()
                        }
                        .onEnded { value in
                            viewModel.currentZoom = (value.magnification - 1) / 10
                            viewModel.setOffset()
                            viewModel.currentZoom = 0
                        }
                    )
                    .highPriorityGesture(
                        DragGesture()
                            .onChanged { value in
                                viewModel.dragAmount = CGSize(
                                    width: value.translation.width / 2,
                                    height: value.translation.height / 2
                                )
                            }
                            .onEnded { value in
                                viewModel.dragAmount = CGSize(
                                    width: value.translation.width / 2,
                                    height: value.translation.height / 2
                                )
                                
                                viewModel.setOffset()
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation {
                            viewModel.reset()
                        }
                    }
                    .onTapGesture {
                        viewModel.scale += 0.1
                    }
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ProfileImageEditView(
            viewModel: ProfileImageEditViewModel(
                dataModel: DataModel(),
                photoURL: nil
            ) { _ in
            }
        )
    }
}
#endif
