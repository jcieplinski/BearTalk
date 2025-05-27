//
//  ImagePickerView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/26/25.
//


import SwiftUI
import PhotosUI

struct ImagePickerView: UIViewControllerRepresentable {
  let imagePicker: ImagePicker
  let onSelect: (UIImage) -> Void
  
  func makeUIViewController(context: Context) -> PHPickerViewController {
    let picker = imagePicker.makeUIViewController(onSelect: onSelect)
    picker.navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .done,
      target: context.coordinator,
      action: #selector(Coordinator.dismiss)
    )
    return picker
  }
  
  func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    // No update needed
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject {
    let parent: ImagePickerView
    
    init(_ parent: ImagePickerView) {
      self.parent = parent
    }
    
    @objc func dismiss() {
      Task { @MainActor in
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
          return
        }
        rootViewController.dismiss(animated: true)
      }
    }
  }
}
