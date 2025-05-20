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
    
    var body: some View {
        ZStack {
            @Bindable var model = model
            if model.selectedModel == .air {
                SceneKitViewAir(sceneName: "Air.scn",
                                showPlatinum: $model.showPlatinum,
                                showGlassRoof: $model.showGlassRoof,
                                carPaintColor: $model.paintColor,
                                selectedWheel: $model.selectedWheel,
                                fancyMirrorCaps: $model.fancyMirrorCaps,
                                shouldResetCamera: $model.shouldResetCamera,
                                onViewCreated: { view in
                    DispatchQueue.main.async {
                        // Configure view for transparency
                        view.backgroundColor = .clear
                        view.scene?.background.contents = nil
                        currentSceneView = view
                    }
                })
            } else if model.selectedModel == .gravity {
                SceneKitViewGravity(showPlatinum: $model.showPlatinum,
                                    carPaintColor: $model.paintColor,
                                    selectedWheel: $model.selectedWheel,
                                    shouldResetCamera: $model.shouldResetCamera,
                                    onViewCreated: { view in
                    DispatchQueue.main.async {
                        // Configure view for transparency
                        view.backgroundColor = .clear
                        view.scene?.background.contents = nil
                        currentSceneView = view
                    }
                })
            } else {
                SceneKitViewSapphire(
                    shouldResetCamera: $model.shouldResetCamera,
                    onViewCreated: { view in
                    DispatchQueue.main.async {
                        // Configure view for transparency
                        view.backgroundColor = .clear
                        view.scene?.background.contents = nil
                        currentSceneView = view
                    }
                })
            }
        }
        .frame(height: 300)
    }
}
