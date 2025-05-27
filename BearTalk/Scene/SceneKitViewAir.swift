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
        
        // Charge port state
        var chargePortNode: SCNNode?
        var isChargePortOpen: Bool = false
        var isAnimating: Bool = false
        var animationPlayer: SCNAnimationPlayer?
        var animationTimer: Timer?
        
        // Frunk state
        var frunkNode: SCNNode?
        var isFrunkOpen: Bool = false
        var isFrunkAnimating: Bool = false
        var frunkAnimationPlayer: SCNAnimationPlayer?
        var frunkAnimationTimer: Timer?
        
        // Trunk state
        var trunkNode: SCNNode?
        var isTrunkOpen: Bool = false
        var isTrunkAnimating: Bool = false
        var trunkAnimationPlayer: SCNAnimationPlayer?
        var trunkAnimationTimer: Timer?
        
        // Door states
        var frontLeftDoorNode: SCNNode?
        var frontRightDoorNode: SCNNode?
        var rearLeftDoorNode: SCNNode?
        var rearRightDoorNode: SCNNode?
        
        var isFrontLeftDoorOpen: Bool = false
        var isFrontRightDoorOpen: Bool = false
        var isRearLeftDoorOpen: Bool = false
        var isRearRightDoorOpen: Bool = false
        
        var isFrontLeftDoorAnimating: Bool = false
        var isFrontRightDoorAnimating: Bool = false
        var isRearLeftDoorAnimating: Bool = false
        var isRearRightDoorAnimating: Bool = false
        
        var frontLeftDoorAnimationPlayer: SCNAnimationPlayer?
        var frontRightDoorAnimationPlayer: SCNAnimationPlayer?
        var rearLeftDoorAnimationPlayer: SCNAnimationPlayer?
        var rearRightDoorAnimationPlayer: SCNAnimationPlayer?
        
        var frontLeftDoorAnimationTimer: Timer?
        var frontRightDoorAnimationTimer: Timer?
        var rearLeftDoorAnimationTimer: Timer?
        var rearRightDoorAnimationTimer: Timer?
        
        var onAnimationComplete: (() -> Void)?
        var onSceneLoaded: (() -> Void)?
        private var displayLink: CADisplayLink?
        private var animationStartTime: CFTimeInterval?
        private var currentAction: SCNAction?
        private var openAction: SCNAction?
        private var closeAction: SCNAction?
        
        deinit {
            // Clean up existing timers
            animationTimer?.invalidate()
            animationTimer = nil
            frunkAnimationTimer?.invalidate()
            frunkAnimationTimer = nil
            trunkAnimationTimer?.invalidate()
            trunkAnimationTimer = nil
            
            // Clean up door timers
            frontLeftDoorAnimationTimer?.invalidate()
            frontLeftDoorAnimationTimer = nil
            frontRightDoorAnimationTimer?.invalidate()
            frontRightDoorAnimationTimer = nil
            rearLeftDoorAnimationTimer?.invalidate()
            rearLeftDoorAnimationTimer = nil
            rearRightDoorAnimationTimer?.invalidate()
            rearRightDoorAnimationTimer = nil
            
            // Clean up existing animation players
            if let player = animationPlayer {
                player.stop()
                animationPlayer = nil
            }
            if let player = frunkAnimationPlayer {
                player.stop()
                frunkAnimationPlayer = nil
            }
            if let player = trunkAnimationPlayer {
                player.stop()
                trunkAnimationPlayer = nil
            }
            
            // Clean up door animation players
            if let player = frontLeftDoorAnimationPlayer {
                player.stop()
                frontLeftDoorAnimationPlayer = nil
            }
            if let player = frontRightDoorAnimationPlayer {
                player.stop()
                frontRightDoorAnimationPlayer = nil
            }
            if let player = rearLeftDoorAnimationPlayer {
                player.stop()
                rearLeftDoorAnimationPlayer = nil
            }
            if let player = rearRightDoorAnimationPlayer {
                player.stop()
                rearRightDoorAnimationPlayer = nil
            }
            
            // Clean up nodes
            chargePortNode = nil
            frunkNode = nil
            trunkNode = nil
            frontLeftDoorNode = nil
            frontRightDoorNode = nil
            rearLeftDoorNode = nil
            rearRightDoorNode = nil
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
                // Store the player
                self.animationPlayer = player
                
                // Configure animation to maintain final state
                player.animation.isRemovedOnCompletion = false
                player.animation.repeatCount = 0  // Play once
                player.animation.autoreverses = false  // Don't reverse
                
                // Set the initial state
                if let state = initialState {
                    if state == .open || state == .ajar {
                        // Set to open position without animation
                        player.stop()
                        player.speed = 1
                        player.animation.timeOffset = player.animation.duration
                        isChargePortOpen = true
                        
                        // Force the animation to update the node's transform
                        player.play()
                        // Use a timer to ensure the animation completes
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                            player.stop()
                        }
                        animationTimer = timer
                    } else {
                        // Set to closed position without animation
                        player.stop()
                        player.speed = 1
                        player.animation.timeOffset = 0
                        isChargePortOpen = false
                        
                        // Force the animation to update the node's transform
                        player.play()
                        // Use a timer to ensure the animation completes
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                            player.stop()
                        }
                        animationTimer = timer
                    }
                } else {
                    // No state available, default to closed
                    player.stop()
                    player.speed = 1
                    player.animation.timeOffset = 0
                    isChargePortOpen = false
                    
                    // Force the animation to update the node's transform
                    player.play()
                    // Use a timer to ensure the animation completes
                    let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                        player.stop()
                    }
                    animationTimer = timer
                }
            } else {
                print("❌ Could not get animation player for key: \(key)")
            }
        }
        
        func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
            isAnimating = false
        }
        
        func animationDidStart(_ anim: CAAnimation) {
            isAnimating = true
        }
        
        func handleChargePortStateChange(_ newState: DoorState) {
            // Don't handle state changes while animating
            if isAnimating {
                return
            }
            
            // Verify animation player state
            if animationPlayer == nil {
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
                toggleChargePort()
            }
        }
        
        func toggleChargePort() {
            // Don't start new animation if one is in progress
            if isAnimating {
                return
            }
            
            guard let player = animationPlayer else {
                return
            }
            
            // Stop current animation if it's playing
            player.stop()
            
            // Set animating flag
            isAnimating = true
            
            if isChargePortOpen {
                // Closing animation
                player.speed = -1
                player.animation.timeOffset = 0
                
                // Use a timer to track animation completion
                let timer = Timer.scheduledTimer(withTimeInterval: player.animation.duration + 0.1, repeats: false) { [weak self] _ in
                    if let self = self {
                        self.isAnimating = false
                        self.isChargePortOpen = false
                    }
                }
                animationTimer = timer
                
                player.play()
            } else {
                // Opening animation
                player.speed = 1
                player.animation.timeOffset = 0
                
                // Use a timer to track animation completion
                let timer = Timer.scheduledTimer(withTimeInterval: player.animation.duration + 0.1, repeats: false) { [weak self] _ in
                    if let self = self {
                        self.isAnimating = false
                        self.isChargePortOpen = true
                    }
                }
                animationTimer = timer
                
                player.play()
            }
        }
        
        func findFrunkNode(in scene: SCNScene) {
            // First try to find by name
            if let node = scene.rootNode.childNode(withName: "Frunk_bonnet_Animation", recursively: true) {
                frunkNode = node
                setupFrunkAnimationPlayer(for: node, initialState: nil)  // Will be set later
            } else {
                // If not found by name, try to find by searching for nodes with animations
                scene.rootNode.enumerateChildNodes { node, _ in
                    if !node.animationKeys.isEmpty,
                       node.name?.lowercased().contains("frunk") ?? false ||
                       node.name?.lowercased().contains("hood") ?? false {
                        frunkNode = node
                        setupFrunkAnimationPlayer(for: node, initialState: nil)  // Will be set later
                    }
                }
            }
            
            if frunkNode == nil {
                print("❌ Could not find frunk node")
            }
        }
        
        func setupFrunkAnimationPlayer(for node: SCNNode, initialState: DoorState?) {
            guard let key = node.animationKeys.first else {
                print("❌ No animation keys found for frunk node")
                return
            }
            
            // Clean up existing animation player if any
            if let existingPlayer = frunkAnimationPlayer {
                existingPlayer.stop()
                frunkAnimationPlayer = nil
            }
            
            // Stop all animations on the node first
            node.animationKeys.forEach { key in
                if let player = node.animationPlayer(forKey: key) {
                    player.stop()
                }
            }
            
            if let player = node.animationPlayer(forKey: key) {
                // Store the player
                self.frunkAnimationPlayer = player
                
                // Configure animation to maintain final state
                player.animation.isRemovedOnCompletion = false
                player.animation.repeatCount = 0  // Play once
                player.animation.autoreverses = false  // Don't reverse
                
                // Set the initial state
                if let state = initialState {
                    if state == .open || state == .ajar {
                        // Set to open position without animation
                        player.stop()
                        player.speed = 1
                        player.animation.timeOffset = player.animation.duration
                        isFrunkOpen = true
                        
                        // Force the animation to update the node's transform
                        player.play()
                        // Use a timer to ensure the animation completes
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                            player.stop()
                        }
                        frunkAnimationTimer = timer
                    } else {
                        // Set to closed position without animation
                        player.stop()
                        player.speed = 1
                        player.animation.timeOffset = 0
                        isFrunkOpen = false
                        
                        // Force the animation to update the node's transform
                        player.play()
                        // Use a timer to ensure the animation completes
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                            player.stop()
                        }
                        frunkAnimationTimer = timer
                    }
                } else {
                    // No state available, default to closed
                    player.stop()
                    player.speed = 1
                    player.animation.timeOffset = 0
                    isFrunkOpen = false
                    
                    // Force the animation to update the node's transform
                    player.play()
                    // Use a timer to ensure the animation completes
                    let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                        player.stop()
                    }
                    frunkAnimationTimer = timer
                }
            } else {
                print("❌ Could not get frunk animation player for key: \(key)")
            }
        }
        
        func handleFrunkStateChange(_ newState: DoorState) {
            // Don't handle state changes while animating
            if isFrunkAnimating {
                return
            }
            
            // Verify animation player state
            if frunkAnimationPlayer == nil {
                if let node = frunkNode {
                    setupFrunkAnimationPlayer(for: node, initialState: nil)
                } else {
                    return
                }
            }
            
            let shouldBeOpen = newState == .open || newState == .ajar
            
            // Only trigger animation if the frunk's state doesn't match desired state
            if shouldBeOpen != isFrunkOpen {
                toggleFrunk()
            }
        }
        
        func toggleFrunk() {
            // Don't start new animation if one is in progress
            if isFrunkAnimating {
                return
            }
            
            guard let player = frunkAnimationPlayer else {
                print("❌ Cannot toggle frunk - animation player missing")
                return
            }
            
            // Stop current animation if it's playing
            player.stop()
            
            // Set animating flag
            isFrunkAnimating = true
            
            if isFrunkOpen {
                // Closing animation
                player.speed = -1
                player.animation.timeOffset = 0
                
                // Use a timer to track animation completion
                let timer = Timer.scheduledTimer(withTimeInterval: player.animation.duration + 0.1, repeats: false) { [weak self] _ in
                    if let self = self {
                        self.isFrunkAnimating = false
                        self.isFrunkOpen = false
                    }
                }
                frunkAnimationTimer = timer
                
                player.play()
            } else {
                // Opening animation
                player.speed = 1
                player.animation.timeOffset = 0
                
                // Use a timer to track animation completion
                let timer = Timer.scheduledTimer(withTimeInterval: player.animation.duration + 0.1, repeats: false) { [weak self] _ in
                    if let self = self {
                        self.isFrunkAnimating = false
                        self.isFrunkOpen = true
                    }
                }
                frunkAnimationTimer = timer
                
                player.play()
            }
        }
        
        func findTrunkNode(in scene: SCNScene) {
            // First try to find by name
            if let node = scene.rootNode.childNode(withName: "Trunk_Animation", recursively: true) {
                trunkNode = node
                setupTrunkAnimationPlayer(for: node, initialState: nil)  // Will be set later
            } else {
                // If not found by name, try to find by searching for nodes with animations
                scene.rootNode.enumerateChildNodes { node, _ in
                    if !node.animationKeys.isEmpty,
                       node.name?.lowercased().contains("trunk") ?? false ||
                       node.name?.lowercased().contains("boot") ?? false {
                        trunkNode = node
                        setupTrunkAnimationPlayer(for: node, initialState: nil)  // Will be set later
                    }
                }
            }
            
            if trunkNode == nil {
                print("❌ Could not find trunk node")
            }
        }
        
        func setupTrunkAnimationPlayer(for node: SCNNode, initialState: DoorState?) {
            guard let key = node.animationKeys.first else {
                print("❌ No animation keys found for trunk node")
                return
            }
            
            // Clean up existing animation player if any
            if let existingPlayer = trunkAnimationPlayer {
                existingPlayer.stop()
                trunkAnimationPlayer = nil
            }
            
            // Stop all animations on the node first
            node.animationKeys.forEach { key in
                if let player = node.animationPlayer(forKey: key) {
                    player.stop()
                }
            }
            
            if let player = node.animationPlayer(forKey: key) {
                // Store the player
                self.trunkAnimationPlayer = player
                
                // Configure animation to maintain final state
                player.animation.isRemovedOnCompletion = false
                player.animation.repeatCount = 0  // Play once
                player.animation.autoreverses = false  // Don't reverse
                
                // Set the initial state
                if let state = initialState {
                    if state == .open || state == .ajar {
                        // Set to open position without animation
                        player.stop()
                        player.speed = 1
                        player.animation.timeOffset = player.animation.duration
                        isTrunkOpen = true
                        
                        // Force the animation to update the node's transform
                        player.play()
                        // Use a timer to ensure the animation completes
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                            player.stop()
                        }
                        trunkAnimationTimer = timer
                    } else {
                        // Set to closed position without animation
                        player.stop()
                        player.speed = 1
                        player.animation.timeOffset = 0
                        isTrunkOpen = false
                        
                        // Force the animation to update the node's transform
                        player.play()
                        // Use a timer to ensure the animation completes
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                            player.stop()
                        }
                        trunkAnimationTimer = timer
                    }
                } else {
                    // No state available, default to closed
                    player.stop()
                    player.speed = 1
                    player.animation.timeOffset = 0
                    isTrunkOpen = false
                    
                    // Force the animation to update the node's transform
                    player.play()
                    // Use a timer to ensure the animation completes
                    let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                        player.stop()
                    }
                    trunkAnimationTimer = timer
                }
            } else {
                print("❌ Could not get trunk animation player for key: \(key)")
            }
        }
        
        func handleTrunkStateChange(_ newState: DoorState) {
            // Don't handle state changes while animating
            if isTrunkAnimating {
                return
            }
            
            // Verify animation player state
            if trunkAnimationPlayer == nil {
                if let node = trunkNode {
                    setupTrunkAnimationPlayer(for: node, initialState: nil)
                } else {
                    return
                }
            }
            
            let shouldBeOpen = newState == .open || newState == .ajar
            
            // Only trigger animation if the trunk's state doesn't match desired state
            if shouldBeOpen != isTrunkOpen {
                toggleTrunk()
            }
        }
        
        func toggleTrunk() {
            // Don't start new animation if one is in progress
            if isTrunkAnimating {
                return
            }
            
            guard let player = trunkAnimationPlayer else {
                return
            }
            
            // Stop current animation if it's playing
            player.stop()
            
            // Set animating flag
            isTrunkAnimating = true
            
            if isTrunkOpen {
                // Closing animation
                player.speed = -1
                player.animation.timeOffset = 0
                
                // Use a timer to track animation completion
                let timer = Timer.scheduledTimer(withTimeInterval: player.animation.duration + 0.1, repeats: false) { [weak self] _ in
                    if let self = self {
                        self.isTrunkAnimating = false
                        self.isTrunkOpen = false
                    }
                }
                trunkAnimationTimer = timer
                
                player.play()
            } else {
                // Opening animation
                player.speed = 1
                player.animation.timeOffset = 0
                
                // Use a timer to track animation completion
                let timer = Timer.scheduledTimer(withTimeInterval: player.animation.duration + 0.1, repeats: false) { [weak self] _ in
                    if let self = self {
                        self.isTrunkAnimating = false
                        self.isTrunkOpen = true
                    }
                }
                trunkAnimationTimer = timer
                
                player.play()
            }
        }
        
        func findDoorNodes(in scene: SCNScene) {
            // Find front left door
            if let node = scene.rootNode.childNode(withName: "Door_01_FL_Animation", recursively: true) {
                frontLeftDoorNode = node
                setupDoorAnimationPlayer(for: node, initialState: nil, doorType: .frontLeft)
            } else {
                print("❌ Could not find front left door node")
            }
            
            // Find front right door
            if let node = scene.rootNode.childNode(withName: "Door_02_FR_Animation", recursively: true) {
                frontRightDoorNode = node
                setupDoorAnimationPlayer(for: node, initialState: nil, doorType: .frontRight)
            } else {
                print("❌ Could not find front right door node")
            }
            
            // Find rear left door
            if let node = scene.rootNode.childNode(withName: "Door_03_RL_Animation", recursively: true) {
                rearLeftDoorNode = node
                setupDoorAnimationPlayer(for: node, initialState: nil, doorType: .rearLeft)
            } else {
                print("❌ Could not find rear left door node")
            }
            
            // Find rear right door
            if let node = scene.rootNode.childNode(withName: "Door_04_RR_Animation", recursively: true) {
                rearRightDoorNode = node
                setupDoorAnimationPlayer(for: node, initialState: nil, doorType: .rearRight)
            } else {
                print("❌ Could not find rear right door node")
            }
        }
        
        enum DoorType {
            case frontLeft
            case frontRight
            case rearLeft
            case rearRight
        }
        
        func setupDoorAnimationPlayer(for node: SCNNode, initialState: DoorState?, doorType: DoorType) {
            guard let key = node.animationKeys.first else {
                print("❌ No animation keys found for door node")
                return
            }
            
            // Get the appropriate animation player based on door type
            var animationPlayer: SCNAnimationPlayer?
            
            switch doorType {
            case .frontLeft:
                animationPlayer = frontLeftDoorAnimationPlayer
            case .frontRight:
                animationPlayer = frontRightDoorAnimationPlayer
            case .rearLeft:
                animationPlayer = rearLeftDoorAnimationPlayer
            case .rearRight:
                animationPlayer = rearRightDoorAnimationPlayer
            }
            
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
                // Store the player based on door type
                switch doorType {
                case .frontLeft:
                    self.frontLeftDoorAnimationPlayer = player
                case .frontRight:
                    self.frontRightDoorAnimationPlayer = player
                case .rearLeft:
                    self.rearLeftDoorAnimationPlayer = player
                case .rearRight:
                    self.rearRightDoorAnimationPlayer = player
                }
                
                // Configure animation to maintain final state
                player.animation.isRemovedOnCompletion = false
                player.animation.repeatCount = 0  // Play once
                player.animation.autoreverses = false  // Don't reverse
                
                // Set the initial state
                if let state = initialState {
                    if state == .open || state == .ajar {
                        // Set to open position without animation
                        player.stop()
                        player.speed = 1
                        player.animation.timeOffset = player.animation.duration
                        
                        // Update the appropriate open state
                        switch doorType {
                        case .frontLeft: self.isFrontLeftDoorOpen = true
                        case .frontRight: self.isFrontRightDoorOpen = true
                        case .rearLeft: self.isRearLeftDoorOpen = true
                        case .rearRight: self.isRearRightDoorOpen = true
                        }
                        
                        // Force the animation to update the node's transform
                        player.play()
                        // Use a timer to ensure the animation completes
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                            player.stop()
                        }
                        
                        // Store the timer based on door type
                        switch doorType {
                        case .frontLeft: self.frontLeftDoorAnimationTimer = timer
                        case .frontRight: self.frontRightDoorAnimationTimer = timer
                        case .rearLeft: self.rearLeftDoorAnimationTimer = timer
                        case .rearRight: self.rearRightDoorAnimationTimer = timer
                        }
                    } else {
                        // Set to closed position without animation
                        player.stop()
                        player.speed = 1
                        player.animation.timeOffset = 0
                        
                        // Update the appropriate open state
                        switch doorType {
                        case .frontLeft: self.isFrontLeftDoorOpen = false
                        case .frontRight: self.isFrontRightDoorOpen = false
                        case .rearLeft: self.isRearLeftDoorOpen = false
                        case .rearRight: self.isRearRightDoorOpen = false
                        }
                        
                        // Force the animation to update the node's transform
                        player.play()
                        // Use a timer to ensure the animation completes
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                            player.stop()
                        }
                        
                        // Store the timer based on door type
                        switch doorType {
                        case .frontLeft: self.frontLeftDoorAnimationTimer = timer
                        case .frontRight: self.frontRightDoorAnimationTimer = timer
                        case .rearLeft: self.rearLeftDoorAnimationTimer = timer
                        case .rearRight: self.rearRightDoorAnimationTimer = timer
                        }
                    }
                } else {
                    // No state available, default to closed
                    player.stop()
                    player.speed = 1
                    player.animation.timeOffset = 0
                    
                    // Update the appropriate open state
                    switch doorType {
                    case .frontLeft: self.isFrontLeftDoorOpen = false
                    case .frontRight: self.isFrontRightDoorOpen = false
                    case .rearLeft: self.isRearLeftDoorOpen = false
                    case .rearRight: self.isRearRightDoorOpen = false
                    }
                    
                    // Force the animation to update the node's transform
                    player.play()
                    // Use a timer to ensure the animation completes
                    let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                        player.stop()
                    }
                    
                    // Store the timer based on door type
                    switch doorType {
                    case .frontLeft: self.frontLeftDoorAnimationTimer = timer
                    case .frontRight: self.frontRightDoorAnimationTimer = timer
                    case .rearLeft: self.rearLeftDoorAnimationTimer = timer
                    case .rearRight: self.rearRightDoorAnimationTimer = timer
                    }
                }
            } else {
                print("❌ Could not get door animation player for key: \(key)")
            }
        }
        
        func handleDoorStateChange(_ newState: DoorState, doorType: DoorType) {
            // Get the appropriate state variables based on door type
            var isAnimating: Bool
            var isOpen: Bool
            var node: SCNNode?
            var animationPlayer: SCNAnimationPlayer?
            
            switch doorType {
            case .frontLeft:
                isAnimating = isFrontLeftDoorAnimating
                isOpen = isFrontLeftDoorOpen
                node = frontLeftDoorNode
                animationPlayer = frontLeftDoorAnimationPlayer
            case .frontRight:
                isAnimating = isFrontRightDoorAnimating
                isOpen = isFrontRightDoorOpen
                node = frontRightDoorNode
                animationPlayer = frontRightDoorAnimationPlayer
            case .rearLeft:
                isAnimating = isRearLeftDoorAnimating
                isOpen = isRearLeftDoorOpen
                node = rearLeftDoorNode
                animationPlayer = rearLeftDoorAnimationPlayer
            case .rearRight:
                isAnimating = isRearRightDoorAnimating
                isOpen = isRearRightDoorOpen
                node = rearRightDoorNode
                animationPlayer = rearRightDoorAnimationPlayer
            }
            
            // Don't handle state changes while animating
            if isAnimating {
                return
            }
            
            // Verify animation player state
            if animationPlayer == nil {
                if let node = node {
                    setupDoorAnimationPlayer(for: node, initialState: nil, doorType: doorType)
                } else {
                    print("❌ Cannot reinitialize - door node is nil")
                    return
                }
            }
            
            let shouldBeOpen = newState == .open || newState == .ajar
            
            // Only trigger animation if the door's state doesn't match desired state
            if shouldBeOpen != isOpen {
                toggleDoor(doorType: doorType)
            }
        }
        
        func toggleDoor(doorType: DoorType) {
            // Get the appropriate state variables based on door type
            var isAnimating: Bool
            var isOpen: Bool
            var animationPlayer: SCNAnimationPlayer?
            
            switch doorType {
            case .frontLeft:
                isAnimating = isFrontLeftDoorAnimating
                isOpen = isFrontLeftDoorOpen
                animationPlayer = frontLeftDoorAnimationPlayer
            case .frontRight:
                isAnimating = isFrontRightDoorAnimating
                isOpen = isFrontRightDoorOpen
                animationPlayer = frontRightDoorAnimationPlayer
            case .rearLeft:
                isAnimating = isRearLeftDoorAnimating
                isOpen = isRearLeftDoorOpen
                animationPlayer = rearLeftDoorAnimationPlayer
            case .rearRight:
                isAnimating = isRearRightDoorAnimating
                isOpen = isRearRightDoorOpen
                animationPlayer = rearRightDoorAnimationPlayer
            }
            
            // Don't start new animation if one is in progress
            if isAnimating {
                return
            }
            
            guard let player = animationPlayer else {
                return
            }
            
            // Stop current animation if it's playing
            player.stop()
            
            // Set animating flag based on door type
            switch doorType {
            case .frontLeft: isFrontLeftDoorAnimating = true
            case .frontRight: isFrontRightDoorAnimating = true
            case .rearLeft: isRearLeftDoorAnimating = true
            case .rearRight: isRearRightDoorAnimating = true
            }
            
            if isOpen {
                // Closing animation
                player.speed = -1
                player.animation.timeOffset = 0
                
                // Use a timer to track animation completion
                let timer = Timer.scheduledTimer(withTimeInterval: player.animation.duration + 0.1, repeats: false) { [weak self] _ in
                    if let self = self {
                        // Update animating and open states based on door type
                        switch doorType {
                        case .frontLeft:
                            self.isFrontLeftDoorAnimating = false
                            self.isFrontLeftDoorOpen = false
                        case .frontRight:
                            self.isFrontRightDoorAnimating = false
                            self.isFrontRightDoorOpen = false
                        case .rearLeft:
                            self.isRearLeftDoorAnimating = false
                            self.isRearLeftDoorOpen = false
                        case .rearRight:
                            self.isRearRightDoorAnimating = false
                            self.isRearRightDoorOpen = false
                        }
                    }
                }
                
                // Store the timer based on door type
                switch doorType {
                case .frontLeft: self.frontLeftDoorAnimationTimer = timer
                case .frontRight: self.frontRightDoorAnimationTimer = timer
                case .rearLeft: self.rearLeftDoorAnimationTimer = timer
                case .rearRight: self.rearRightDoorAnimationTimer = timer
                }
                
                player.play()
            } else {
                // Opening animation
                player.speed = 1
                player.animation.timeOffset = 0
                
                // Use a timer to track animation completion
                let timer = Timer.scheduledTimer(withTimeInterval: player.animation.duration + 0.1, repeats: false) { [weak self] _ in
                    if let self = self {
                        // Update animating and open states based on door type
                        switch doorType {
                        case .frontLeft:
                            self.isFrontLeftDoorAnimating = false
                            self.isFrontLeftDoorOpen = true
                        case .frontRight:
                            self.isFrontRightDoorAnimating = false
                            self.isFrontRightDoorOpen = true
                        case .rearLeft:
                            self.isRearLeftDoorAnimating = false
                            self.isRearLeftDoorOpen = true
                        case .rearRight:
                            self.isRearRightDoorAnimating = false
                            self.isRearRightDoorOpen = true
                        }
                    }
                }
                
                // Store the timer based on door type
                switch doorType {
                case .frontLeft: self.frontLeftDoorAnimationTimer = timer
                case .frontRight: self.frontRightDoorAnimationTimer = timer
                case .rearLeft: self.rearLeftDoorAnimationTimer = timer
                case .rearRight: self.rearRightDoorAnimationTimer = timer
                }
                
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
            
            // Find the frunk node and its animation
            context.coordinator.findFrunkNode(in: loadedScene)
            
            // Find the trunk node and its animation
            context.coordinator.findTrunkNode(in: loadedScene)
            
            // Find the door nodes and their animations
            context.coordinator.findDoorNodes(in: loadedScene)
            
            // Check initial charge port state and set it without animation
            let chargePortState = model.chargePortClosureState
            
            // Set up the initial state immediately
            if let node = context.coordinator.chargePortNode,
               let player = node.animationPlayer(forKey: node.animationKeys.first ?? "") {
                
                // Stop any existing animations
                player.stop()
                
                // Set the animation state
                player.speed = 1
                if chargePortState == .open || chargePortState == .ajar {
                    // Just play the animation normally
                    player.animation.timeOffset = 0
                    player.play()
                    
                    // Wait for animation to complete
                    let timer = Timer.scheduledTimer(withTimeInterval: player.animation.duration + 0.1, repeats: false) { _ in
                        context.coordinator.isChargePortOpen = true
                        isSceneLoaded = true
                    }
                    context.coordinator.animationTimer = timer
                } else {
                    player.animation.timeOffset = 0
                    context.coordinator.isChargePortOpen = false
                    player.play()
                    
                    // Mark scene as loaded after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isSceneLoaded = true
                    }
                }
            } else {
                // Ensure charge port is closed by default
                if let node = context.coordinator.chargePortNode,
                   let player = node.animationPlayer(forKey: node.animationKeys.first ?? "") {
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
            
            // Check initial frunk state and set it without animation
            if let frunkState = model.frunkClosureState {
                
                // Set up the initial state immediately
                if let node = context.coordinator.frunkNode,
                   let player = node.animationPlayer(forKey: node.animationKeys.first ?? "") {
                    
                    // Stop any existing animations
                    player.stop()
                    
                    // Set the animation state
                    player.speed = 1
                    if frunkState == .open || frunkState == .ajar {
                        // Just play the animation normally
                        player.animation.timeOffset = 0
                        player.play()
                        
                        // Wait for animation to complete
                        let timer = Timer.scheduledTimer(withTimeInterval: player.animation.duration + 0.1, repeats: false) { _ in
                            context.coordinator.isFrunkOpen = true
                            isSceneLoaded = true
                        }
                        context.coordinator.frunkAnimationTimer = timer
                    } else {
                        player.animation.timeOffset = 0
                        context.coordinator.isFrunkOpen = false
                        player.play()
                        
                        // Mark scene as loaded after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isSceneLoaded = true
                        }
                    }
                }
            } else {
                // Ensure frunk is closed by default
                if let node = context.coordinator.frunkNode,
                   let player = node.animationPlayer(forKey: node.animationKeys.first ?? "") {
                    player.stop()
                    player.speed = 1
                    player.animation.timeOffset = 0
                    context.coordinator.isFrunkOpen = false
                    player.play()
                    
                    // Mark scene as loaded after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isSceneLoaded = true
                    }
                }
            }
            
            // Check initial trunk state and set it without animation
            if let trunkState = model.trunkClosureState {
                // Set up the initial state immediately
                if let node = context.coordinator.trunkNode,
                   let player = node.animationPlayer(forKey: node.animationKeys.first ?? "") {
                    // Stop any existing animations
                    player.stop()
                    
                    // Set the animation state
                    player.speed = 1
                    if trunkState == .open || trunkState == .ajar {
                        // Just play the animation normally
                        player.animation.timeOffset = 0
                        player.play()
                        
                        // Wait for animation to complete
                        let timer = Timer.scheduledTimer(withTimeInterval: player.animation.duration + 0.1, repeats: false) { _ in
                            context.coordinator.isTrunkOpen = true
                            isSceneLoaded = true
                        }
                        context.coordinator.trunkAnimationTimer = timer
                    } else {
                        player.animation.timeOffset = 0
                        context.coordinator.isTrunkOpen = false
                        player.play()
                        
                        // Mark scene as loaded after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isSceneLoaded = true
                        }
                    }
                }
            } else {
                // Ensure trunk is closed by default
                if let node = context.coordinator.trunkNode,
                   let player = node.animationPlayer(forKey: node.animationKeys.first ?? "") {
                    player.stop()
                    player.speed = 1
                    player.animation.timeOffset = 0
                    context.coordinator.isTrunkOpen = false
                    player.play()
                    
                    // Mark scene as loaded after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isSceneLoaded = true
                    }
                }
            }
            
            // Check initial door states and set them without animation
            context.coordinator.handleDoorStateChange(model.frontLeftDoorClosureState, doorType: .frontLeft)
            
            context.coordinator.handleDoorStateChange(model.frontRightDoorClosureState, doorType: .frontRight)
            
            context.coordinator.handleDoorStateChange(model.rearLeftDoorClosureState, doorType: .rearLeft)
            
            context.coordinator.handleDoorStateChange(model.rearRightDoorClosureState, doorType: .rearRight)
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
            if isSceneLoaded {
                // Handle charge port state changes
                let chargePortState = model.chargePortClosureState
                if !context.coordinator.isAnimating {
                    context.coordinator.handleChargePortStateChange(chargePortState)
                }
                
                // Handle frunk state changes
                if let frunkState = model.frunkClosureState {
                    if !context.coordinator.isFrunkAnimating {
                        context.coordinator.handleFrunkStateChange(frunkState)
                    }
                }
                
                // Handle trunk state changes
                if let trunkState = model.trunkClosureState {
                    if !context.coordinator.isTrunkAnimating {
                        context.coordinator.handleTrunkStateChange(trunkState)
                    }
                }
                
                // Handle door state changes
                if !context.coordinator.isFrontLeftDoorAnimating {
                    context.coordinator.handleDoorStateChange(model.frontLeftDoorClosureState, doorType: .frontLeft)
                }
                
                if !context.coordinator.isFrontRightDoorAnimating {
                    context.coordinator.handleDoorStateChange(model.frontRightDoorClosureState, doorType: .frontRight)
                }
                
                if !context.coordinator.isRearLeftDoorAnimating {
                    context.coordinator.handleDoorStateChange(model.rearLeftDoorClosureState, doorType: .rearLeft)
                }
                
                if !context.coordinator.isRearRightDoorAnimating {
                    context.coordinator.handleDoorStateChange(model.rearRightDoorClosureState, doorType: .rearRight)
                }
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
