//
//  CarView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/20/25.
//

import SwiftUI
import SceneKit

struct CarView: View {
    @Environment(DataModel.self) var model
    
    @State private var currentSceneView: SCNView?
    @State private var isSceneLoaded = false
    @State private var sceneOpacity: Double = 0
    
    var body: some View {
        ZStack {
            @Bindable var model = model
            ZStack {
                if model.selectedModel == .air {
                    SceneKitViewAir(sceneName: "Air.scn",
                                    showPlatinum: $model.showPlatinum,
                                    showGlassRoof: $model.showGlassRoof,
                                    carPaintColor: $model.paintColor,
                                    selectedWheel: $model.selectedWheel,
                                    fancyMirrorCaps: $model.fancyMirrorCaps,
                                    shouldResetCamera: $model.shouldResetCamera,
                                    isSceneLoaded: $isSceneLoaded,
                                    onViewCreated: { view in
                        DispatchQueue.main.async {
                            // Configure view for transparency
                            view.backgroundColor = .clear
                            view.scene?.background.contents = nil
                            currentSceneView = view
                        }
                    })
                    .opacity(sceneOpacity)
                } else if model.selectedModel == .gravity {
                    SceneKitViewGravity(showPlatinum: $model.showPlatinum,
                                        carPaintColor: $model.paintColor,
                                        selectedWheel: $model.selectedWheel,
                                        shouldResetCamera: $model.shouldResetCamera,
                                        isSceneLoaded: $isSceneLoaded,
                                        onViewCreated: { view in
                        DispatchQueue.main.async {
                            // Configure view for transparency
                            view.backgroundColor = .clear
                            view.scene?.background.contents = nil
                            currentSceneView = view
                        }
                    })
                    .opacity(sceneOpacity)
                } else {
                    SceneKitViewSapphire(
                        shouldResetCamera: $model.shouldResetCamera,
                        isSceneLoaded: $isSceneLoaded,
                        onViewCreated: { view in
                        DispatchQueue.main.async {
                            // Configure view for transparency
                            view.backgroundColor = .clear
                            view.scene?.background.contents = nil
                            currentSceneView = view
                        }
                    })
                    .opacity(sceneOpacity)
                }
            }
            .frame(height: 200)
        }
        .overlay(alignment: .center, content: {
            if !isSceneLoaded {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.secondary)
                    .scaleEffect(1.5)
                    .transition(.scale)
            }
        })
        .overlay(alignment: .bottomLeading) {
            Button {
                model.shouldResetCamera.toggle()
            } label: {
                Label("Reset view", systemImage: "arrow.clockwise.circle.fill")
                    .labelStyle(.iconOnly)
                    .font(.title)
                    .padding()
            }
            .tint(.secondary)
            .opacity(isSceneLoaded ? sceneOpacity : 0)
        }
        .onChange(of: isSceneLoaded) { _, newValue in
            if newValue {
                // Ensure the scene is fully loaded before starting fade
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        sceneOpacity = 1
                    }
                }
            }
        }
        .onChange(of: model.selectedModel) { _, _ in
            // Reset states when model changes
            withAnimation(.easeOut(duration: 0.2)) {
                sceneOpacity = 0
            }
            isSceneLoaded = false
        }
    }
}
