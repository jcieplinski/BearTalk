//
//  CircleCutOut.swift
//  Alma
//
//  Created by Joe Cieplinski on 1/11/25.
//

import SwiftUI

struct CircleCutOut: Shape {
  let size: CGSize
  
  func path(in rect: CGRect) -> Path {
    let path = CGMutablePath()
    path.move(to: rect.origin)
    path.addLine(to: .init(x: rect.maxX, y: rect.minY))
    path.addLine(to: .init(x: rect.maxX, y: rect.maxY))
    path.addLine(to: .init(x: rect.minX, y: rect.maxY))
    path.addLine(to: rect.origin)
    path.closeSubpath()
    
    let newRect = CGRect(origin: .init(x: rect.midX - size.width/2.0, y: rect.midY - size.height/2.0), size: size)
    
//    path.move(to: newRect.origin)
//    path.addLine(to: .init(x: newRect.maxX, y: newRect.minY))
//    path.addLine(to: .init(x: newRect.maxX, y: newRect.maxY))
//    path.addLine(to: .init(x: newRect.minX, y: newRect.maxY))
//    path.addLine(to: newRect.origin)
//    path.closeSubpath()
    
    // Add circular cutout
    path.addEllipse(in: newRect)
    
    return Path(path)
  }
}
