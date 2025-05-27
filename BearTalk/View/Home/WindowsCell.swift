//
//  WindowsCell.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/20/25.
//

import SwiftUI

struct WindowsCell: View {
    @Environment(DataModel.self) var model
    @State private var showWindowsSheet = false
    
    private var windowStatus: String {
        guard let windowPosition = model.windowPosition else { return "Unknown" }
        
        if !windowPosition.isOpen {
            return "Closed"
        }
        
        var openWindows: [String] = []
        
        if windowPosition.leftFront != .fullyClosed {
            openWindows.append("Front Left")
        }
        if windowPosition.rightFront != .fullyClosed {
            openWindows.append("Front Right")
        }
        if windowPosition.leftRear != .fullyClosed {
            openWindows.append("Rear Left")
        }
        if windowPosition.rightRear != .fullyClosed {
            openWindows.append("Rear Right")
        }
        
        return openWindows.joined(separator: ", ")
    }
    
    var body: some View {
        NavigationLink {
            WindowsSheet(isModelPresntation: false)
        } label: {
            VStack(spacing: 16) {
                HStack {
                    Text("Windows")
                        .font(.headline)
                    
                    Spacer()
                }
                
                HStack {
                    Text(windowStatus)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    WindowsCell()
        .environment(DataModel())
} 
