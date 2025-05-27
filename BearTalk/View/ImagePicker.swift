//
//  ImagePicker.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/26/25.
//

import SwiftUI
import PhotosUI

class ImagePicker: NSObject {
  // Hold a strong reference to the delegate
  private var pickerDelegate: ImagePickerDelegate?
  
  func makeUIViewController(onSelect: @escaping (UIImage) -> Void) -> PHPickerViewController {
    var config = PHPickerConfiguration(photoLibrary: .shared())
    config.filter = .images
    config.selectionLimit = 1
    config.selection = .continuous
    
    let picker = PHPickerViewController(configuration: config)
    pickerDelegate = ImagePickerDelegate(onSelect: onSelect)
    picker.delegate = pickerDelegate
    return picker
  }
}

private class ImagePickerDelegate: NSObject, PHPickerViewControllerDelegate {
  let onSelect: (UIImage) -> Void
  
  init(onSelect: @escaping (UIImage) -> Void) {
    self.onSelect = onSelect
  }
  
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    guard let result = results.first else { 
      picker.dismiss(animated: true)
      return
    }
    
    result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
      if let error = error {
        print("Error loading image: \(error)")
        return
      }
      
      if let image = image as? UIImage {
        let fixedOrientationImage = image.fixedOrientation()
        DispatchQueue.main.async {
          self?.onSelect(fixedOrientationImage)
        }
      }
    }

    picker.dismiss(animated: true)
  }
}
