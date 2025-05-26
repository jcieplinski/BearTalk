//
//  SceneKitViewAir.swift
//  SceneTest
//
//  Created by Joe Cieplinski on 5/18/25.
//

import SwiftUI
import SceneKit
import OSLog

struct SceneKitViewAir: UIViewRepresentable {
    let sceneName: String
    @Binding var showPlatinum: Bool
    @Binding var showGlassRoof: Bool
    @Binding var carPaintColor: PaintColor
    @Binding var selectedWheel: Wheels
    @Binding var fancyMirrorCaps: Bool
    @Binding var shouldResetCamera: Bool
    @Binding var isSceneLoaded: Bool
    @Environment(DataModel.self) var model  // Add DataModel environment
    let onViewCreated: (SCNView) -> Void
    
    // Add Coordinator
    final class Coordinator: NSObject, CAAnimationDelegate {
        var initialCameraNode: SCNNode?
        var initialCameraTransform: SCNMatrix4?
        var initialCameraOrientation: SCNQuaternion?
        var initialCameraPosition: SCNVector3?
        var initialCameraFOV: CGFloat?
        var initialLookAtPoint: SCNVector3?
        var isResetting = false
        var sceneView: SCNView?
        var chargePortNode: SCNNode?
        var isChargePortOpen: Bool = false
        var isAnimating: Bool = false
        var animationPlayer: SCNAnimationPlayer?
        var animationTimer: Timer?
        var onAnimationComplete: (() -> Void)?
        var onSceneLoaded: (() -> Void)?
        private var displayLink: CADisplayLink?
        private var animationStartTime: CFTimeInterval?
        private var currentAction: SCNAction?
        private var openAction: SCNAction?
        private var closeAction: SCNAction?
        
        deinit {
            print("🧹 Cleaning up Coordinator")
            animationTimer?.invalidate()
            animationTimer = nil
            
            // Clean up animation player
            if let player = animationPlayer {
                player.stop()
                animationPlayer = nil
            }
            
            // Clean up charge port node
            chargePortNode = nil
        }
        
        func storeInitialCameraState(_ node: SCNNode) {
            // Store all camera properties
            initialCameraNode = node
            
            // Store the transform and orientation from the world transform
            let worldTransform = node.worldTransform
            initialCameraTransform = worldTransform
            
            // Extract position from world transform
            initialCameraPosition = SCNVector3(worldTransform.m41, worldTransform.m42, worldTransform.m43)
            
            // Store the orientation directly from the node
            initialCameraOrientation = node.worldOrientation
            
            // Store the initial field of view
            if let camera = node.camera {
                initialCameraFOV = camera.fieldOfView
            }
        }
        
        func resetCamera(_ node: SCNNode, in view: SCNView) {
            guard !isResetting,
                  let initialTransform = initialCameraTransform,
                  let initialFOV = initialCameraFOV,
                  let initialOrientation = initialCameraOrientation else {
                print("Failed to reset camera - missing initial state or already resetting")
                return
            }
            
            isResetting = true
            
            
            // Disable camera controls temporarily
            view.allowsCameraControl = false
            
            // Store current camera state
            let currentPosition = node.position
            let currentOrientation = node.orientation
            let currentFOV = node.camera?.fieldOfView ?? initialFOV
            
            // Set up animation
            let duration: TimeInterval = 0.5
            let startTime = CACurrentMediaTime()
            
            // Animation function
            func animate() {
                let elapsed = CACurrentMediaTime() - startTime
                let progress = min(elapsed / duration, 1.0)
                
                // Use ease-in-ease-out timing
                let t = progress < 0.5 ? 2 * progress * progress : 1 - pow(-2 * progress + 2, 2) / 2
                
                // Interpolate position
                let targetPosition = initialCameraPosition ?? SCNVector3Zero
                let newPosition = SCNVector3(
                    currentPosition.x + (targetPosition.x - currentPosition.x) * Float(t),
                    currentPosition.y + (targetPosition.y - currentPosition.y) * Float(t),
                    currentPosition.z + (targetPosition.z - currentPosition.z) * Float(t)
                )
                
                // Interpolate orientation using SLERP
                let newOrientation = SCNQuaternion.slerp(
                    currentOrientation,
                    initialOrientation,
                    Float(t)
                )
                
                // Interpolate FOV
                let newFOV = currentFOV + (initialFOV - currentFOV) * t
                
                // Update camera
                node.position = newPosition
                node.orientation = newOrientation
                node.camera?.fieldOfView = newFOV
                
                if progress < 1.0 {
                    // Continue animation
                    DispatchQueue.main.async {
                        animate()
                    }
                } else {
                    // Animation complete - ensure all camera properties are exactly restored
                    node.transform = initialTransform
                    node.position = initialCameraPosition ?? SCNVector3Zero
                    node.orientation = initialOrientation
                    if let camera = node.camera {
                        camera.fieldOfView = initialFOV
                    }
                    
                    // Re-enable camera controls
                    view.allowsCameraControl = true
                    self.isResetting = false
                }
            }
            
            // Start animation
            animate()
        }
        
        func findChargePortNode(in scene: SCNScene) {
            print("🔍 Searching for charge port node...")
            
            // First try to find by name
            if let node = scene.rootNode.childNode(withName: "charge_port", recursively: true) {
                print("✅ Found charge port node by name: \(node.name ?? "unnamed")")
                chargePortNode = node
                setupAnimationPlayer(for: node, initialState: nil)  // Will be set later
            } else {
                print("🔍 Charge port not found by name, searching all nodes...")
                // If not found by name, try to find by searching for nodes with animations
                scene.rootNode.enumerateChildNodes { node, _ in
                    if !node.animationKeys.isEmpty,
                       node.name?.lowercased().contains("charge") ?? false ||
                       node.name?.lowercased().contains("port") ?? false {
                        print("✅ Found potential charge port node: \(node.name ?? "unnamed")")
                        print("📋 Node animation keys: \(node.animationKeys)")
                        chargePortNode = node
                        setupAnimationPlayer(for: node, initialState: nil)  // Will be set later
                    }
                }
            }
            
            if chargePortNode == nil {
                print("❌ Could not find charge port node")
            }
        }
        
        func setupAnimationPlayer(for node: SCNNode, initialState: DoorState?) {
            guard let key = node.animationKeys.first else {
                print("❌ No animation keys found for node")
                return
            }
            
            print("🔍 Setting up animation player for node: \(node.name ?? "unnamed")")
            print("📋 Animation keys: \(node.animationKeys)")
            
            // Clean up existing animation player if any
            if let existingPlayer = animationPlayer {
                existingPlayer.stop()
                animationPlayer = nil
            }
            
            // Stop all animations on the node first
            node.animationKeys.forEach { key in
                if let player = node.animationPlayer(forKey: key) {
                    player.stop()
                }
            }
            
            if let player = node.animationPlayer(forKey: key) {
                print("✅ Found animation player for key: \(key)")
                print("📊 Animation duration: \(player.animation.duration)")
                print("📊 Animation type: \(type(of: player.animation))")
                print("📊 Current animation state - speed: \(player.speed), timeOffset: \(player.animation.timeOffset)")
                
                // Store the player
                self.animationPlayer = player
                
                // Configure animation to maintain final state
                player.animation.isRemovedOnCompletion = false
                player.animation.repeatCount = 0  // Play once
                player.animation.autoreverses = false  // Don't reverse
                
                // Store the initial transform
                let initialTransform = node.transform
                print("📊 Initial node transform: \(initialTransform)")
                
                // Set the initial state
                if let state = initialState {
                    print("🚪 Setting up animation player with initial state: \(state)")
                    if state == .open || state == .ajar {
                        // Set to open position without animation
                        print("🚪 Setting to open position")
                        player.stop()
                        player.speed = 1
                        player.animation.timeOffset = player.animation.duration
                        isChargePortOpen = true
                        
                        // Force the animation to update the node's transform
                        player.play()
                        // Use a timer to ensure the animation completes
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
                            guard let self = self else { return }
                            player.stop()
                            print("📊 Node transform after setting open: \(node.transform)")
                        }
                        animationTimer = timer
                    } else {
                        // Set to closed position without animation
                        print("🚪 Setting to closed position")
                        player.stop()
                        player.speed = 1
                        player.animation.timeOffset = 0
                        isChargePortOpen = false
                        
                        // Force the animation to update the node's transform
                        player.play()
                        // Use a timer to ensure the animation completes
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
                            guard let self = self else { return }
                            player.stop()
                            print("📊 Node transform after setting closed: \(node.transform)")
                        }
                        animationTimer = timer
                    }
                } else {
                    // No state available, default to closed
                    print("🚪 No state available, defaulting to closed position")
                    player.stop()
                    player.speed = 1
                    player.animation.timeOffset = 0
                    isChargePortOpen = false
                    
                    // Force the animation to update the node's transform
                    player.play()
                    // Use a timer to ensure the animation completes
                    let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
                        guard let self = self else { return }
                        player.stop()
                        print("📊 Node transform after setting default closed: \(node.transform)")
                    }
                    animationTimer = timer
                }
                
                print("📊 Final node transform after setup: \(node.transform)")
                print("✅ Animation player configured - isRemovedOnCompletion: \(player.animation.isRemovedOnCompletion), repeatCount: \(player.animation.repeatCount), autoreverses: \(player.animation.autoreverses)")
            } else {
                print("❌ Could not get animation player for key: \(key)")
            }
        }
        
        func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
            print("🎬 Animation did stop - finished: \(flag)")
            isAnimating = false
        }
        
        func animationDidStart(_ anim: CAAnimation) {
            print("🎬 Animation did start")
            isAnimating = true
        }
        
        func handleChargePortStateChange(_ newState: DoorState) {
            print("🔄 Handling charge port state change to: \(newState)")
            
            // Don't handle state changes while animating
            if isAnimating {
                print("⏳ Animation in progress, ignoring state change")
                return
            }
            
            // Verify animation player state
            if animationPlayer == nil {
                print("⚠️ Animation player is nil, attempting to reinitialize...")
                if let node = chargePortNode {
                    setupAnimationPlayer(for: node, initialState: nil)
                } else {
                    print("❌ Cannot reinitialize - charge port node is nil")
                    return
                }
            }
            
            let shouldBeOpen = newState == .open || newState == .ajar
            
            // Only trigger animation if the door's state doesn't match desired state
            if shouldBeOpen != isChargePortOpen {
                print(shouldBeOpen ? "🚪 Opening charge port" : "🚪 Closing charge port")
                toggleChargePort()
            } else {
                print("ℹ️ Door already in desired state")
            }
        }
        
        func toggleChargePort() {
            print("🔄 Toggling charge port...")
            
            // Don't start new animation if one is in progress
            if isAnimating {
                print("⏳ Animation in progress, ignoring toggle")
                return
            }
            
            guard let player = animationPlayer,
                  let _ = chargePortNode else {
                print("❌ Cannot toggle - animation player or node missing")
                return
            }
            
            // Stop current animation if it's playing
            player.stop()
            
            // Set animating flag
            isAnimating = true
            
            if isChargePortOpen {
                // Closing animation
                print("▶️ Starting closing animation")
                player.speed = -1
                player.animation.timeOffset = player.animation.duration
                
                // Use a timer to track animation completion
                let timer = Timer.scheduledTimer(withTimeInterval: player.animation.duration + 0.1, repeats: false) { [weak self] _ in
                    if let self = self {
                        print("✅ Closing animation completed")
                        self.isAnimating = false
                        self.isChargePortOpen = false
                    }
                }
                animationTimer = timer
                
                player.play()
            } else {
                // Opening animation
                print("▶️ Starting opening animation")
                player.speed = 1
                player.animation.timeOffset = 0
                
                // Use a timer to track animation completion
                let timer = Timer.scheduledTimer(withTimeInterval: player.animation.duration + 0.1, repeats: false) { [weak self] _ in
                    if let self = self {
                        print("✅ Opening animation completed")
                        self.isAnimating = false
                        self.isChargePortOpen = true
                    }
                }
                animationTimer = timer
                
                player.play()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.tag = 1
        
        // Configure view for transparency
        sceneView.backgroundColor = .clear
        sceneView.isOpaque = false
        
        // Store the reference in the coordinator
        context.coordinator.sceneView = sceneView
        
        // Call the callback
        onViewCreated(sceneView)
        
        // Configure camera controls to only allow horizontal rotation
        sceneView.defaultCameraController.interactionMode = .orbitAngleMapping
        sceneView.defaultCameraController.target = SCNVector3Zero  // Orbit around origin
        sceneView.defaultCameraController.maximumVerticalAngle = 0  // Prevent vertical rotation
        sceneView.defaultCameraController.minimumVerticalAngle = 0  // Prevent vertical rotation
        sceneView.defaultCameraController.inertiaEnabled = true     // Smooth rotation
        sceneView.defaultCameraController.inertiaFriction = 0.1     // Adjust rotation speed
        
        // Try multiple approaches to load the scene
        var scene: SCNScene?
        
        // Approach 1: Try loading directly from the main bundle
        if let sceneURL = Bundle.main.url(forResource: "Air", withExtension: "scn") {
            do {
                scene = try SCNScene(url: sceneURL, options: [
                    SCNSceneSource.LoadingOption.animationImportPolicy: SCNSceneSource.AnimationImportPolicy.doNotPlay
                ])
            } catch {
                Logger.vehicle.error("Error loading scene from URL: \(error)")
            }
        } else {
            Logger.vehicle.error("Could not find scene file in bundle")
            
            // Approach 2: Try loading from the main bundle without subdirectory
            if let sceneURL = Bundle.main.url(forResource: "Lucid3D96", withExtension: "scn") {
                do {
                    scene = try SCNScene(url: sceneURL, options: [
                        SCNSceneSource.LoadingOption.animationImportPolicy: SCNSceneSource.AnimationImportPolicy.doNotPlay
                    ])
                } catch {
                    Logger.vehicle.error("Error loading scene from root URL: \(error)")
                }
            } else {
                Logger.vehicle.error("Could not find scene file at root level")
            }
        }
        
        // If we have a scene, set it up
        if let loadedScene = scene { 
            sceneView.scene = loadedScene
            
            // Set scene background to clear
            loadedScene.background.contents = UIColor.clear
            
            // Stop all animations in the scene
            loadedScene.rootNode.enumerateChildNodes { node, _ in
                node.animationKeys.forEach { key in
                    if let player = node.animationPlayer(forKey: key) {
                        player.stop()
                    }
                }
            }
            
            // Enable animation
            sceneView.rendersContinuously = true
            sceneView.autoenablesDefaultLighting = true
            sceneView.allowsCameraControl = true
            
            // Add ambient light to ensure proper lighting
            let ambientLight = SCNNode()
            ambientLight.light = SCNLight()
            ambientLight.light?.type = .ambient
            ambientLight.light?.color = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)  // Slightly warm white
            ambientLight.light?.intensity = 300
            loadedScene.rootNode.addChildNode(ambientLight)
            
            // Add a directional light for better definition
            let directionalLight = SCNNode()
            directionalLight.light = SCNLight()
            directionalLight.light?.type = .directional
            directionalLight.light?.color = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)  // Slightly warm white
            directionalLight.light?.intensity = 800
            directionalLight.light?.castsShadow = true
            directionalLight.light?.shadowRadius = 8.0
            directionalLight.light?.shadowSampleCount = 16
            directionalLight.light?.shadowMode = .deferred
            directionalLight.light?.shadowBias = 0.005
            directionalLight.light?.shadowColor = UIColor(white: 0, alpha: 0.3)
            directionalLight.position = SCNVector3(x: 5, y: 5, z: 5)
            directionalLight.eulerAngles = SCNVector3(x: -Float.pi/4, y: Float.pi/4, z: 0)
            loadedScene.rootNode.addChildNode(directionalLight)
            
            // Set initial visibility based on binding
            updateNodeVisibility(in: loadedScene, showPlatinum: showPlatinum, showGlassRoof: showGlassRoof)
            
            // Update carpaint material with initial color
            updateCarPaintMaterial(in: loadedScene, color: carPaintColor.color)
            
            // Try to find the camera
            if let cameraNode = loadedScene.rootNode.childNode(withName: "camera_default", recursively: true) {
                // Store the initial camera state BEFORE setting as point of view
                context.coordinator.storeInitialCameraState(cameraNode)
                
                // Set as point of view
                sceneView.pointOfView = cameraNode
            } else {
                Logger.vehicle.error("Could not find defaultCamera, using default camera")
                // Create a default camera if we can't find the one in the scene
                let camera = SCNCamera()
                let cameraNode = SCNNode()
                cameraNode.camera = camera
                cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
                loadedScene.rootNode.addChildNode(cameraNode)
                sceneView.pointOfView = cameraNode
                
                // Store the initial camera state
                context.coordinator.storeInitialCameraState(cameraNode)
            }
            
            // Find the charge port node and its animation
            context.coordinator.findChargePortNode(in: loadedScene)
            
            // Check initial charge port state and set it without animation
            if let chargePortState = model.chargePortClosureState {
                print("🚪 Initial charge port state from model: \(chargePortState)")
                
                // Set up the initial state immediately
                if let node = context.coordinator.chargePortNode,
                   let player = node.animationPlayer(forKey: node.animationKeys.first ?? "") {
                    print("🚪 Setting initial state: \(chargePortState)")
                    
                    // Stop any existing animations
                    player.stop()
                    
                    // Set the animation state
                    player.speed = 1
                    if chargePortState == .open || chargePortState == .ajar {
                        print("🚪 Setting to open position")
                        // Just play the animation normally
                        player.animation.timeOffset = 0
                        player.play()
                        
                        // Wait for animation to complete
                        let timer = Timer.scheduledTimer(withTimeInterval: player.animation.duration + 0.1, repeats: false) { _ in
                            print("✅ Initial opening animation completed")
                            context.coordinator.isChargePortOpen = true
                            isSceneLoaded = true
                        }
                        context.coordinator.animationTimer = timer
                    } else {
                        print("🚪 Setting to closed position")
                        player.animation.timeOffset = 0
                        context.coordinator.isChargePortOpen = false
                        player.play()
                        
                        // Mark scene as loaded after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isSceneLoaded = true
                        }
                    }
                }
            } else {
                print("❓ No charge port state available")
                // Ensure charge port is closed by default
                if let node = context.coordinator.chargePortNode,
                   let player = node.animationPlayer(forKey: node.animationKeys.first ?? "") {
                    print("🚪 Setting default closed state")
                    player.stop()
                    player.speed = 1
                    player.animation.timeOffset = 0
                    context.coordinator.isChargePortOpen = false
                    player.play()
                    
                    // Mark scene as loaded after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isSceneLoaded = true
                    }
                }
            }
        } else {
            Logger.vehicle.error("Failed to load scene using all available methods")
        }
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        if let scene = uiView.scene {
            updateNodeVisibility(in: scene, showPlatinum: showPlatinum, showGlassRoof: showGlassRoof)
            updateCarPaintMaterial(in: scene, color: carPaintColor.color)
            updateWheelVisibility(in: scene, selectedWheel: selectedWheel.nodeTitle)
            
            // Handle camera reset
            if shouldResetCamera && !context.coordinator.isResetting {
                if let cameraNode = uiView.pointOfView {
                    context.coordinator.resetCamera(cameraNode, in: uiView)
                    
                    // Only reset the flag after the animation completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        shouldResetCamera = false
                    }
                } else {
                    print("Failed to reset camera - no camera node found")
                    shouldResetCamera = false
                }
            }
            
            // Only handle state changes after the initial setup is complete and we're not animating
            if isSceneLoaded && !context.coordinator.isAnimating,
               let chargePortState = model.chargePortClosureState {
                context.coordinator.handleChargePortStateChange(chargePortState)
            }
        }
    }
    
    private func updateNodeVisibility(in scene: SCNScene, showPlatinum: Bool, showGlassRoof: Bool) {
        // Use Sets to prevent duplicates
        var platinumNodes = Set<SCNNode>()
        var stealthNodes = Set<SCNNode>()
        var glassRoofNodes = Set<SCNNode>()
        var metalRoofNodes = Set<SCNNode>()
        var glassRoofPlatinumNodes = Set<SCNNode>()
        var glassRoofStealthNodes = Set<SCNNode>()
        var metalRoofPlatinumNodes = Set<SCNNode>()
        var metalRoofStealthNodes = Set<SCNNode>()
        var mirrorCapPlatinumNodes = Set<SCNNode>()
        var mirrorCapStealthNodes = Set<SCNNode>()
        var mirrorCapCarPaintNodes = Set<SCNNode>()
        var rimPlatinumNodes = Set<SCNNode>()
        var rimStealthNodes = Set<SCNNode>()
        
        // First pass: categorize nodes
        scene.rootNode.enumerateChildNodes { node, _ in
            guard let nodeName = node.name?.lowercased() else { return }
            
            // Check for rim materials
            if let materials = node.geometry?.materials {
                for material in materials {
                    if let materialName = material.name?.lowercased() {
                        if materialName == "rim_outside-l" {
                            rimPlatinumNodes.insert(node)
                        } else if materialName == "rim_outside_stealth-l" {
                            rimStealthNodes.insert(node)
                        }
                    }
                }
            }
            
            // Check for mirror caps first
            if nodeName.contains("mirrorcap") {
                if nodeName.hasSuffix("_platinum") {
                    mirrorCapPlatinumNodes.insert(node)
                } else if nodeName.hasSuffix("_stealth") {
                    mirrorCapStealthNodes.insert(node)
                } else if nodeName.contains("carpaint") {
                    mirrorCapCarPaintNodes.insert(node)
                }
            }
            // Then check for roof-related nodes
            else if nodeName.contains("glassroof") {
                if nodeName.hasSuffix("_platinum") {
                    glassRoofPlatinumNodes.insert(node)
                } else if nodeName.hasSuffix("_stealth") {
                    glassRoofStealthNodes.insert(node)
                } else {
                    glassRoofNodes.insert(node)
                }
            } else if nodeName.contains("metalroof") {
                if nodeName.hasSuffix("_platinum") {
                    metalRoofPlatinumNodes.insert(node)
                } else if nodeName.hasSuffix("_stealth") {
                    metalRoofStealthNodes.insert(node)
                } else {
                    metalRoofNodes.insert(node)
                }
            } else {
                // Non-roof, non-mirror platinum/stealth nodes
                if nodeName.hasSuffix("_platinum") {
                    platinumNodes.insert(node)
                } else if nodeName.hasSuffix("_stealth") {
                    stealthNodes.insert(node)
                }
            }
        }
        
        // Handle rim materials based on platinum/stealth state
        let stealthRimMaterial = rimStealthNodes.first?.geometry?.material(named: "rim_outside_stealth-l")
        let platinumRimMaterial = rimPlatinumNodes.first?.geometry?.material(named: "rim_outside-l")
        
        rimPlatinumNodes.forEach { node in
            if let name = node.name,
                name.contains("rim_outside"),
               let stealthRimMaterial,
                let platinumRimMaterial
            {
                node.geometry?.materials.removeAll()
                node.geometry?.materials.append(showPlatinum ? platinumRimMaterial : stealthRimMaterial)
            }
        }
        
        rimStealthNodes.forEach { node in
            if let name = node.name,
               name.contains("rim_outside"),
               let stealthRimMaterial,
               let platinumRimMaterial
            {
                node.geometry?.materials.removeAll()
                node.geometry?.materials.append(showPlatinum ? platinumRimMaterial : stealthRimMaterial)
            }
        }
        
        // Handle mirror caps based on GT state
        if fancyMirrorCaps {
            // GT mode: show platinum/stealth based on showPlatinum
            mirrorCapPlatinumNodes.forEach { node in
                var parent = node.parent
                while parent != nil {
                    parent?.isHidden = false
                    parent = parent?.parent
                }
                node.isHidden = !showPlatinum
            }
            mirrorCapStealthNodes.forEach { node in
                var parent = node.parent
                while parent != nil {
                    parent?.isHidden = false
                    parent = parent?.parent
                }
                node.isHidden = showPlatinum
            }
            // Hide car paint mirror caps in GT mode
            mirrorCapCarPaintNodes.forEach { node in
                node.isHidden = true
            }
        } else {
            // Non-GT mode: show car paint, hide platinum/stealth
            mirrorCapCarPaintNodes.forEach { node in
                var parent = node.parent
                while parent != nil {
                    parent?.isHidden = false
                    parent = parent?.parent
                }
                node.isHidden = false
            }
            // Hide platinum/stealth mirror caps in non-GT mode
            mirrorCapPlatinumNodes.forEach { node in
                node.isHidden = true
            }
            mirrorCapStealthNodes.forEach { node in
                node.isHidden = true
            }
        }
        
        // First update roof visibility
        // When showGlassRoof is true: show glass roof nodes, hide metal roof nodes
        // When showGlassRoof is false: hide glass roof nodes, show metal roof nodes
        glassRoofNodes.forEach { node in
            // Ensure parent nodes are visible
            var parent = node.parent
            while parent != nil {
                parent?.isHidden = false
                parent = parent?.parent
            }
            node.isHidden = !showGlassRoof
        }
        
        metalRoofNodes.forEach { node in
            // Ensure parent nodes are visible
            var parent = node.parent
            while parent != nil {
                parent?.isHidden = false
                parent = parent?.parent
            }
            node.isHidden = showGlassRoof
        }
        
        // Then update roof platinum/stealth variants based on both roof type and platinum state
        if showGlassRoof {
            // Glass roof is visible, handle its platinum/stealth variants
            glassRoofPlatinumNodes.forEach { node in
                var parent = node.parent
                while parent != nil {
                    parent?.isHidden = false
                    parent = parent?.parent
                }
                node.isHidden = !showPlatinum
            }
            glassRoofStealthNodes.forEach { node in
                var parent = node.parent
                while parent != nil {
                    parent?.isHidden = false
                    parent = parent?.parent
                }
                node.isHidden = showPlatinum
            }
            // Hide all metal roof variants
            metalRoofPlatinumNodes.forEach { node in
                node.isHidden = true
            }
            metalRoofStealthNodes.forEach { node in
                node.isHidden = true
            }
        } else {
            // Metal roof is visible, handle its platinum/stealth variants
            metalRoofPlatinumNodes.forEach { node in
                var parent = node.parent
                while parent != nil {
                    parent?.isHidden = false
                    parent = parent?.parent
                }
                node.isHidden = !showPlatinum
            }
            metalRoofStealthNodes.forEach { node in
                var parent = node.parent
                while parent != nil {
                    parent?.isHidden = false
                    parent = parent?.parent
                }
                node.isHidden = showPlatinum
            }
            // Hide all glass roof variants
            glassRoofPlatinumNodes.forEach { node in
                node.isHidden = true
            }
            glassRoofStealthNodes.forEach { node in
                node.isHidden = true
            }
        }
        
        // Finally update non-roof platinum/stealth nodes
        platinumNodes.forEach { node in
            var parent = node.parent
            while parent != nil {
                parent?.isHidden = false
                parent = parent?.parent
            }
            node.isHidden = !showPlatinum
        }
        
        stealthNodes.forEach { node in
            var parent = node.parent
            while parent != nil {
                parent?.isHidden = false
                parent = parent?.parent
            }
            node.isHidden = showPlatinum
        }
    }
    
    private func updateCarPaintMaterial(in scene: SCNScene, color: Color) {
        // Convert SwiftUI Color to UIColor
        let uiColor = UIColor(color)
        
        // Find all nodes with materials
        scene.rootNode.enumerateChildNodes { node, _ in
            if let materials = node.geometry?.materials {
                for material in materials {
                    if material.name?.lowercased().contains("carpaint") ?? false {
                        // Update the diffuse color
                        material.diffuse.contents = uiColor
                    }
                }
            }
        }
    }
    
    private func updateWheelVisibility(in scene: SCNScene, selectedWheel: String?) {
        // Find only the parent wheel nodes (those without additional suffixes)
        let parentWheelNodes = scene.rootNode.childNodes(passingTest: { node, _ in
            guard let nodeName = node.name else { return false }
            return nodeName.hasPrefix("Wheel_") && 
                   !nodeName.contains("_01_") && 
                   !nodeName.contains("_02_") && 
                   !nodeName.contains("_03_") && 
                   !nodeName.contains("_04_")
        })
        
        parentWheelNodes.forEach { node in
        }
        
        // Update visibility based on selection
        parentWheelNodes.forEach { node in
            if let nodeName = node.name {
                if let selected = selectedWheel {
                    let shouldHide = nodeName != selected
                    node.isHidden = shouldHide
                } else {
                    node.isHidden = false
                }
            }
        }
    }
}

// Helper extension for quaternion interpolation
extension SCNQuaternion {
    static func slerp(_ q1: SCNQuaternion, _ q2: SCNQuaternion, _ t: Float) -> SCNQuaternion {
        var q1 = q1
        var q2 = q2
        
        // Normalize inputs
        let q1Length = sqrt(q1.x * q1.x + q1.y * q1.y + q1.z * q1.z + q1.w * q1.w)
        let q2Length = sqrt(q2.x * q2.x + q2.y * q2.y + q2.z * q2.z + q2.w * q2.w)
        
        q1.x /= q1Length
        q1.y /= q1Length
        q1.z /= q1Length
        q1.w /= q1Length
        
        q2.x /= q2Length
        q2.y /= q2Length
        q2.z /= q2Length
        q2.w /= q2Length
        
        // Compute dot product
        var dot = q1.x * q2.x + q1.y * q2.y + q1.z * q2.z + q1.w * q2.w
        
        // If dot product is negative, negate one of the quaternions
        if dot < 0 {
            q2.x = -q2.x
            q2.y = -q2.y
            q2.z = -q2.z
            q2.w = -q2.w
            dot = -dot
        }
        
        // If the quaternions are very close, just return q1
        if dot > 0.9995 {
            return q1
        }
        
        // Perform SLERP
        let theta = acos(dot)
        let sinTheta = sin(theta)
        let w1 = sin((1 - t) * theta) / sinTheta
        let w2 = sin(t * theta) / sinTheta
        
        return SCNQuaternion(
            x: w1 * q1.x + w2 * q2.x,
            y: w1 * q1.y + w2 * q2.y,
            z: w1 * q1.z + w2 * q2.z,
            w: w1 * q1.w + w2 * q2.w
        )
    }
}
