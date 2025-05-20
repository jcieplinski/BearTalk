//
//  CarView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/20/25.
//

import SwiftUI
import SceneKit

struct CarView: View {
    @Binding var selectedModel: CarSceneModel
    @Binding var showPlatinum: Bool
    @Binding var showGlassRoof: Bool
    @Binding var paintColor: PaintColor
    @Binding var selectedWheel: Wheels
    @Binding var isGT: Bool
    @Binding var shouldResetCamera: Bool
    
    @State private var currentSceneView: SCNView?
    
    var body: some View {
        ZStack {
            if selectedModel == .air {
                SceneKitViewAir(sceneName: "Air.scn",
                                showPlatinum: $showPlatinum,
                                showGlassRoof: $showGlassRoof,
                                carPaintColor: $paintColor,
                                selectedWheel: $selectedWheel,
                                isGT: $isGT,
                                shouldResetCamera: $shouldResetCamera,
                                onViewCreated: { view in
                    DispatchQueue.main.async {
                        // Configure view for transparency
                        view.backgroundColor = .clear
                        view.scene?.background.contents = nil
                        currentSceneView = view
                    }
                })
            } else if selectedModel == .gravity {
                SceneKitViewGravity(showPlatinum: $showPlatinum,
                                    carPaintColor: $paintColor,
                                    selectedWheel: $selectedWheel,
                                    shouldResetCamera: $shouldResetCamera,
                                    onViewCreated: { view in
                    DispatchQueue.main.async {
                        // Configure view for transparency
                        view.backgroundColor = .clear
                        view.scene?.background.contents = nil
                        currentSceneView = view
                    }
                })
            } else {
                SceneKitViewSapphire(shouldResetCamera: $shouldResetCamera,
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
        .frame(height: 340)
        .background(Color.black)
    }
}
