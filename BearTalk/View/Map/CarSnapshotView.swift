import SwiftUI
import SceneKit

struct CarSnapshotView: View {
    @Environment(DataModel.self) var model
    @State private var snapshot: UIImage?
    @State private var isGeneratingSnapshot = false
    
    var body: some View {
        Group {
            if let snapshot = snapshot {
                Image(uiImage: snapshot)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Color.clear
                    .frame(width: 80, height: 80)
            }
        }
        .onAppear {
            generateSnapshot()
        }
        .onChange(of: model.paintColor) {
            generateSnapshot()
        }
        .onChange(of: model.selectedWheel) {
            generateSnapshot()
        }
        .onChange(of: model.showPlatinum) {
            generateSnapshot()
        }
        .onChange(of: model.showGlassRoof) {
            generateSnapshot()
        }
        .onChange(of: model.fancyMirrorCaps) {
            generateSnapshot()
        }
    }
    
    private func generateSnapshot() {
        // Prevent duplicate snapshot generation
        guard !isGeneratingSnapshot else { return }
        isGeneratingSnapshot = true
        
        print("Generating car snapshot...")
        
        // Create a temporary SceneKit view
        let sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        sceneView.backgroundColor = .clear
        sceneView.autoenablesDefaultLighting = true
        sceneView.rendersContinuously = true
        sceneView.preferredFramesPerSecond = 60
        sceneView.antialiasingMode = .multisampling4X
        sceneView.isOpaque = false  // Make the view non-opaque
        
        // Load the appropriate scene based on the selected model
        var scene: SCNScene?
        if model.selectedModel == .air {
            print("Loading Air scene...")
            if let sceneURL = Bundle.main.url(forResource: "Air", withExtension: "scn") {
                do {
                    scene = try SCNScene(url: sceneURL, options: nil)
                    print("Successfully loaded Air scene")
                } catch {
                    print("Error loading Air scene: \(error)")
                }
            }
        } else if model.selectedModel == .gravity {
            print("Loading Gravity scene...")
            if let sceneURL = Bundle.main.url(forResource: "Gravity", withExtension: "scn") {
                do {
                    scene = try SCNScene(url: sceneURL, options: nil)
                    print("Successfully loaded Gravity scene")
                } catch {
                    print("Error loading Gravity scene: \(error)")
                }
            }
        } else if model.selectedModel == .sapphire {
            print("Loading Sapphire scene...")
            if let sceneURL = Bundle.main.url(forResource: "Sapphire", withExtension: "scn") {
                do {
                    scene = try SCNScene(url: sceneURL, options: nil)
                    print("Successfully loaded Sapphire scene")
                } catch {
                    print("Error loading Sapphire scene: \(error)")
                }
            }
        }
        
        if let loadedScene = scene {
            print("Setting up scene...")
            sceneView.scene = loadedScene
            loadedScene.background.contents = UIColor.clear  // Make the scene background clear
            
            // Find and set the interactive camera
            if let cameraNode = loadedScene.rootNode.childNode(withName: "camera_interactive", recursively: true) {
                print("Found interactive camera node")
                sceneView.pointOfView = cameraNode
            } else {
                print("Could not find interactive camera, using default camera")
                let camera = SCNCamera()
                let cameraNode = SCNNode()
                cameraNode.camera = camera
                cameraNode.position = SCNVector3(x: 0, y: 2.5, z: 4.5)
                cameraNode.eulerAngles = SCNVector3(x: -Float.pi/6, y: 0, z: 0)
                loadedScene.rootNode.addChildNode(cameraNode)
                sceneView.pointOfView = cameraNode
            }
            
            // Update materials and visibility
            updateMaterials(in: loadedScene)
            
            // Ensure the scene is rendered
            sceneView.layoutIfNeeded()
            
            // Wait for the scene to be ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                print("Taking snapshot...")
                let snapshot = sceneView.snapshot()
                print("Snapshot taken")
                
                DispatchQueue.main.async {
                    self.snapshot = snapshot
                    self.isGeneratingSnapshot = false
                }
            }
        } else {
            print("Failed to load scene")
            isGeneratingSnapshot = false
        }
    }
    
    private func updateMaterials(in scene: SCNScene) {
        print("Updating materials...")
        
        // Skip material updates for Sapphire
        if model.selectedModel == .sapphire {
            print("Skipping material updates for Sapphire model")
            return
        }
        
        // Update car paint color
        let paintUIColor = UIColor(model.paintColor.color)
        scene.rootNode.enumerateChildNodes { node, _ in
            if let geometry = node.geometry {
                for material in geometry.materials {
                    if let materialName = material.name?.lowercased() {
                        // Check for both carPaint and car_paint naming conventions
                        if materialName.contains("carpaint") || materialName.contains("car_paint") {
                            material.diffuse.contents = paintUIColor
                            print("Updated paint material: \(materialName)")
                        }
                    }
                }
            }
        }
        
        // Handle platinum/stealth materials differently based on model
        if model.selectedModel == .gravity {
            // Gravity uses material colors for platinum/stealth
            let materialNames = [
                "Stealth_Platinum_ext_cantrail",
                "Stealth_Platinum_ext_rim_outside",
                "bonnet_switch"
            ]
            
            let targetColor = model.showPlatinum ? "#CCCCCC" : "#4E4E4E"
            guard let color = Color(hex: targetColor) else { return }
            let uiColor = UIColor(color)
            
            scene.rootNode.enumerateChildNodes { node, _ in
                if let materials = node.geometry?.materials {
                    for material in materials {
                        if let materialName = material.name,
                           materialNames.contains(materialName) {
                            material.diffuse.contents = uiColor
                            print("Updated platinum material: \(materialName)")
                        }
                    }
                }
            }
        } else {
            // Air uses node visibility for platinum/stealth
            scene.rootNode.enumerateChildNodes { node, _ in
                if let nodeName = node.name?.lowercased() {
                    if nodeName.contains("metalroof") {
                        node.isHidden = model.showGlassRoof
                    } else if nodeName.contains("glassroof") {
                        let isPlatinum = nodeName.hasSuffix("_platinum")
                        let isStealth = nodeName.hasSuffix("_stealth")
                        node.isHidden = !model.showGlassRoof || 
                            (isPlatinum && !model.showPlatinum) ||
                            (isStealth && model.showPlatinum)
                    } else if nodeName.hasSuffix("_platinum") {
                        node.isHidden = !model.showPlatinum
                    } else if nodeName.hasSuffix("_stealth") {
                        node.isHidden = model.showPlatinum
                    }
                }
            }
        }
        
        // Update wheel visibility
        let wheelNodeName = model.selectedWheel.nodeTitle
        scene.rootNode.enumerateChildNodes { node, _ in
            if let nodeName = node.name {
                if model.selectedModel == .gravity {
                    // Gravity uses Wheel_Set prefix
                    if nodeName.hasPrefix("Wheel_Set") && 
                       !nodeName.contains("_01_") && 
                       !nodeName.contains("_02_") && 
                       !nodeName.contains("_03_") && 
                       !nodeName.contains("_04_") {
                        node.isHidden = nodeName != wheelNodeName
                    }
                } else {
                    // Air uses Wheel_ prefix
                    if nodeName.hasPrefix("Wheel_") && 
                       !nodeName.contains("_01_") && 
                       !nodeName.contains("_02_") && 
                       !nodeName.contains("_03_") && 
                       !nodeName.contains("_04_") {
                        node.isHidden = nodeName != wheelNodeName
                    }
                }
            }
        }
        
        print("Materials updated")
    }
}

// Wrapper view that uses CarView with the interactive camera
private struct CarSnapshotWrapperView: View {
    @Environment(DataModel.self) var model
    @State private var sceneView: SCNView?
    @State private var isSceneReady = false
    
    var body: some View {
        ZStack {
            CarView()
                .frame(width: 80, height: 80)
                .background(Color.black.opacity(0.1))
                .onAppear {
                    print("CarSnapshotWrapperView appeared")
                    // Find the SceneKit view and set it to use the interactive camera
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let sceneView = findSceneView() {
                            print("Found SceneKit view")
                            self.sceneView = sceneView
                            setupInteractiveCamera(in: sceneView)
                        } else {
                            print("Failed to find SceneKit view")
                        }
                    }
                }
        }
    }
    
    private func findSceneView() -> SCNView? {
        // Find the SceneKit view in the view hierarchy
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("Failed to get window scene or root view controller")
            return nil
        }
        
        // Search for a view with tag 1 (Air), 2 (Gravity), or 3 (Sapphire)
        for tag in 1...3 {
            if let sceneView = rootViewController.view.viewWithTag(tag) as? SCNView {
                print("Found SceneKit view with tag \(tag)")
                return sceneView
            }
        }
        
        print("No SceneKit view found with tags 1-3")
        return nil
    }
    
    private func setupInteractiveCamera(in sceneView: SCNView) {
        guard let scene = sceneView.scene else {
            print("No scene found in SceneKit view")
            return
        }
        
        print("Setting up interactive camera...")
        
        // Configure the scene view
        sceneView.backgroundColor = .clear
        sceneView.autoenablesDefaultLighting = true
        sceneView.rendersContinuously = true
        sceneView.preferredFramesPerSecond = 60
        sceneView.antialiasingMode = .multisampling4X
        
        // Find and set the interactive camera
        if let cameraNode = scene.rootNode.childNode(withName: "camera_interactive", recursively: true) {
            print("Found interactive camera node")
            sceneView.pointOfView = cameraNode
            
            // Disable camera controls for the snapshot
            sceneView.allowsCameraControl = false
            
            // Ensure the scene is rendered
            sceneView.layoutIfNeeded()
            sceneView.setNeedsDisplay()
            
            // Force a render pass
            sceneView.scene?.rootNode.enumerateChildNodes { node, _ in
                node.isHidden = false
            }
            
            print("Camera setup complete")
        } else {
            print("Could not find interactive camera node")
        }
    }
} 
