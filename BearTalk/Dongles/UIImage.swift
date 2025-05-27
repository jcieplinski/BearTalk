//
//  UIImage.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/26/25.
//


import UIKit

extension UIImage {
  func fixedOrientation() -> UIImage {
    if (imageOrientation == UIImage.Orientation.up) { return self }
    
    var transform:CGAffineTransform = CGAffineTransform.identity
    
    if (imageOrientation == UIImage.Orientation.down || imageOrientation == UIImage.Orientation.downMirrored) {
      transform = transform.translatedBy(x: size.width, y: size.height)
      transform = transform.rotated(by: CGFloat(Double.pi))
    }
    
    if (imageOrientation == UIImage.Orientation.left || imageOrientation == UIImage.Orientation.leftMirrored) {
      transform = transform.translatedBy(x: size.width, y: 0)
      transform = transform.rotated(by: CGFloat(Double.pi/2))
    }
    
    if (imageOrientation == UIImage.Orientation.right || imageOrientation == UIImage.Orientation.rightMirrored) {
      transform = transform.translatedBy(x: 0, y: size.height);
      transform = transform.rotated(by: CGFloat(-Double.pi/2));
    }
    
    if (imageOrientation == UIImage.Orientation.upMirrored || imageOrientation == UIImage.Orientation.downMirrored) {
      transform = transform.translatedBy(x: size.width, y: 0)
      transform = transform.scaledBy(x: -1, y: 1)
    }
    
    if (imageOrientation == UIImage.Orientation.leftMirrored || imageOrientation == UIImage.Orientation.rightMirrored) {
      transform = transform.translatedBy(x: size.height, y: 0);
      transform = transform.scaledBy(x: -1, y: 1);
    }
    
    let ctx:CGContext = CGContext(
      data: nil, width: Int(size.width), height: Int(size.height),
      bitsPerComponent: cgImage!.bitsPerComponent, bytesPerRow: 0,
      space: cgImage!.colorSpace!,
      bitmapInfo: cgImage!.bitmapInfo.rawValue
    )!
    
    ctx.concatenate(transform)
    
    
    if (
      imageOrientation == UIImage.Orientation.left
      || imageOrientation == UIImage.Orientation.leftMirrored
      || imageOrientation == UIImage.Orientation.right
      || imageOrientation == UIImage.Orientation.rightMirrored
    ) {
      ctx.draw(cgImage!, in: CGRect(x:0,y:0,width:size.height,height:size.width))
    } else {
      ctx.draw(cgImage!, in: CGRect(x:0,y:0,width:size.width,height:size.height))
    }
    
    let cgimg:CGImage = ctx.makeImage()!
    let imgEnd:UIImage = UIImage(cgImage: cgimg)
    
    return imgEnd
  }
}

extension UIImage {
    func resizeImageTo(size: CGSize) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
