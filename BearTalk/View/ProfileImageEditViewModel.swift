//
//  ProfileImageEditViewModel.swift
//  Alma
//
//  Created by Joe Cieplinski on 1/12/25.
//

import SwiftUI

@Observable final class ProfileImageEditViewModel {
    var dataModel: DataModel
    var offset = CGSize.zero
    var scale: CGFloat = 1.0
    var inputImage: UIImage
    var resultImage: UIImage?
    var cropSize: CGSize = CGSize(width: 250, height: 250)
    var proxySize: CGSize = .zero
    var isWorking: Bool = false
    var onFinish: ((Bool) -> Void)
    
    var endResultSize: CGSize = CGSize(width: 512, height: 512)
    
    var dragAmount = CGSize.zero {
        didSet {
            offset.width += dragAmount.width * scale
            offset.height += dragAmount.height * scale
        }
    }
    
    var currentZoom: CGFloat = 0 {
        didSet {
            let newScale = scale + currentZoom
            
            scale = max(newScale, minScale)
        }
    }
    
    var minScale: CGFloat {
        guard inputImage.size != .zero else { return 1.0 }
        
        let screenImageWidth = proxySize.width
        let screenImageHeight = (proxySize.width * inputImage.size.height) / inputImage.size.width
        let screenImageSize = CGSize(width: screenImageWidth, height: screenImageHeight)
        
        return max(
            cropSize.width / screenImageSize.width,
            cropSize.height / screenImageSize.height
        )
    }
    
    var maxOffset: CGSize {
        guard inputImage.size != .zero else { return .zero }
        
        let cutOutSquareToHorizontalEdgeDistance = (proxySize.width - cropSize.width) / 2
        let widthScaleEffect = ((proxySize.width * scale) - proxySize.width) / 2
        let maxWidth = cutOutSquareToHorizontalEdgeDistance + widthScaleEffect
        
        let fullHeight = (proxySize.width * inputImage.size.height) / inputImage.size.width
        let scaledHeight = fullHeight * scale
        let maxHeight = (scaledHeight - cropSize.height) / 2
        
        return CGSize(width: maxWidth, height: maxHeight)
    }
    
    @ObservationIgnored
    let imagePicker = ImagePicker()
    
    internal init(
        dataModel: DataModel,
        photoURL: String?,
        dragAmount: CGSize = CGSize.zero,
        scale: CGFloat = 1.0,
        inputImage: UIImage = UIImage(),
        resultImage: UIImage? = nil,
        cropSize: CGSize = CGSize(width: 250, height: 250),
        onFinish: @escaping ((Bool) -> Void)
    ) {
        self.dataModel = dataModel
        self.dragAmount = dragAmount
        self.scale = scale
        self.inputImage = inputImage
        self.resultImage = resultImage
        self.cropSize = cropSize
        self.onFinish = onFinish
        
        if let photoURL {
            Task {
                do {
                    guard let url = URL(string: photoURL) else { return }
                    
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: data) {
                        self.inputImage = image
                    }
                } catch {
                    print("Error downloading profile image: \(error)")
                }
            }
        }
    }
    
    func reset() {
        dragAmount = CGSize.zero
        offset = CGSize.zero
        scale = 1.0
        currentZoom = 0
        resultImage = nil
        cropSize = CGSize(width: 250, height: 250)
    }
    
    func setOffset() {
        dragAmount = .zero
        
        var newOffset: CGSize = .zero
        
        newOffset.width = offset.width >= 0 ?
        min(offset.width, maxOffset.width) :
        max(offset.width, -maxOffset.width)
        
        newOffset.height = offset.height >= 0 ?
        min(offset.height, maxOffset.height) :
        max(offset.height, -maxOffset.height)
        
        withAnimation {
            offset = newOffset
        }
    }
    
    func finish() async throws {
        isWorking = true
        
        do {
            if let cropped = try await crop(), let data = cropped.pngData() {
                let newPhotoUrl = try await dataModel.uploadProfilePhoto(data)
                
                guard let url = URL(string: newPhotoUrl ?? "") else { return }
                
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    self.inputImage = image
                }
                
                isWorking = false
                onFinish(true)
            }
            
            isWorking = false
        } catch {
            print("Could not upload profile image: \(error)")
            isWorking = false
            onFinish(false)
        }
    }
    
    func crop() async throws -> UIImage? {
        let size = proxySize
        let imageSize = inputImage.size
        var scale = max(
            inputImage.size.width / size.width,
            inputImage.size.height / size.height
        )
        
        var zoomScale = self.scale
        
        scale *= 3
        zoomScale *= 3
        
        let currentPositionWidth = offset.width * scale
        let currentPositionHeight = offset.height * scale
        let croppedImageSize = CGSize(
            width: (cropSize.width * scale) / zoomScale,
            height: (cropSize.height * scale) / zoomScale
        )
        
        let xOffset = ((imageSize.width - croppedImageSize.width) / 2.0) - (currentPositionWidth  / zoomScale)
        let yOffset = ((imageSize.height - croppedImageSize.height) / 2.0) - (currentPositionHeight  / zoomScale)
        let croppedImageRect: CGRect = CGRect(x: xOffset, y: yOffset, width: croppedImageSize.width, height: croppedImageSize.height)
        
        if let cropped = inputImage.cgImage?.cropping(to: croppedImageRect) {
            let croppedImage = UIImage(cgImage: cropped)
            return croppedImage.resizeImageTo(size: endResultSize)
        }
        
        return nil
    }
    
    func imageCaptured(_ image: UIImage) {
        inputImage = image
    }
}
