//
//  WindowsCell.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/20/25.
//

import SwiftUI

struct WindowsCell: View {
    @Environment(DataModel.self) var model
    let isWideMode: Bool
    @State private var showSheet = false
    
    private var windowStatus: String {
        guard let windowPosition = model.windowPosition else { return "Unknown" }
        
        if !windowPosition.isOpen {
            return "Closed"
        }
        
        var openWindows: [String] = []
        
        if windowPosition.leftFront.isOpen {
            openWindows.append("Front Left")
        }
        if windowPosition.rightFront.isOpen {
            openWindows.append("Front Right")
        }
        if windowPosition.leftRear.isOpen {
            openWindows.append("Rear Left")
        }
        if windowPosition.rightRear.isOpen {
            openWindows.append("Rear Right")
        }
        
        return openWindows.joined(separator: ", ")
    }
    
    var body: some View {
        Group {
            if isWideMode {
                Button {
                    showSheet = true
                } label: {
                    cellContent
                }
                .buttonStyle(.plain)
            } else {
                NavigationLink {
                    WindowsSheet(isModelPresntation: false)
                } label: {
                    cellContent
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                WindowsSheet(isModelPresntation: false)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            if #available(iOS 26.0, *) {
                                Button(role: .confirm) {
                                    showSheet = false
                                }
                            } else {
                                Button("Done") {
                                    showSheet = false
                                }
                            }
                        }
                    }
            }
            .presentationSizing(.page)
        }
    }
    
    private var cellContent: some View {
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
}

#Preview {
    WindowsCell(isWideMode: false)
        .environment(DataModel())
}
