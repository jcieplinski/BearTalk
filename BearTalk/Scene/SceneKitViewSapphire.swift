import SwiftUI
import SceneKit
import OSLog

struct SceneKitViewSapphire: UIViewRepresentable {
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
            initialCameraNode = node
            let worldTransform = node.worldTransform
            initialCameraTransform = worldTransform
            initialCameraPosition = SCNVector3(worldTransform.m41, worldTransform.m42, worldTransform.m43)
            initialCameraOrientation = node.worldOrientation
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
            view.allowsCameraControl = false
            
            let currentPosition = node.position
            let currentOrientation = node.orientation
            let currentFOV = node.camera?.fieldOfView ?? initialFOV
            
            let duration: TimeInterval = 0.5
            let startTime = CACurrentMediaTime()
            
            func animate() {
                let elapsed = CACurrentMediaTime() - startTime
                let progress = min(elapsed / duration, 1.0)
                let t = progress < 0.5 ? 2 * progress * progress : 1 - pow(-2 * progress + 2, 2) / 2
                
                let targetPosition = initialCameraPosition ?? SCNVector3Zero
                let newPosition = SCNVector3(
                    currentPosition.x + (targetPosition.x - currentPosition.x) * Float(t),
                    currentPosition.y + (targetPosition.y - currentPosition.y) * Float(t),
                    currentPosition.z + (targetPosition.z - currentPosition.z) * Float(t)
                )
                
                let newOrientation = SCNQuaternion.slerp(
                    currentOrientation,
                    initialOrientation,
                    Float(t)
                )
                
                let newFOV = currentFOV + (initialFOV - currentFOV) * t
                
                node.position = newPosition
                node.orientation = newOrientation
                node.camera?.fieldOfView = newFOV
                
                if progress < 1.0 {
                    DispatchQueue.main.async {
                        animate()
                    }
                } else {
                    node.transform = initialTransform
                    node.position = initialCameraPosition ?? SCNVector3Zero
                    node.orientation = initialOrientation
                    if let camera = node.camera {
                        camera.fieldOfView = initialFOV
                    }
                    view.allowsCameraControl = true
                    self.isResetting = false
                }
            }
            
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
        
        enum DoorType {
            case frontLeft
            case frontRight
            case rearLeft
            case rearRight
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
                    let shouldBeOpen = state == .open || state == .ajar
                    player.stop()
                    player.speed = 1
                    player.animation.timeOffset = shouldBeOpen ? player.animation.duration : 0
                    
                    // Update open state
                    switch doorType {
                    case .frontLeft: self.isFrontLeftDoorOpen = shouldBeOpen
                    case .frontRight: self.isFrontRightDoorOpen = shouldBeOpen
                    case .rearLeft: self.isRearLeftDoorOpen = shouldBeOpen
                    case .rearRight: self.isRearRightDoorOpen = shouldBeOpen
                    }
                    
                    // Force animation update
                    player.play()
                    let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                        player.stop()
                    }
                    
                    // Store timer
                    switch doorType {
                    case .frontLeft: self.frontLeftDoorAnimationTimer = timer
                    case .frontRight: self.frontRightDoorAnimationTimer = timer
                    case .rearLeft: self.rearLeftDoorAnimationTimer = timer
                    case .rearRight: self.rearRightDoorAnimationTimer = timer
                    }
                } else {
                    // Default to closed
                    player.stop()
                    player.speed = 1
                    player.animation.timeOffset = 0
                    
                    // Update open state
                    switch doorType {
                    case .frontLeft: self.isFrontLeftDoorOpen = false
                    case .frontRight: self.isFrontRightDoorOpen = false
                    case .rearLeft: self.isRearLeftDoorOpen = false
                    case .rearRight: self.isRearRightDoorOpen = false
                    }
                    
                    // Force animation update
                    player.play()
                    let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                        player.stop()
                    }
                    
                    // Store timer
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
            // Get state variables
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
            
            if isAnimating { return }
            
            if animationPlayer == nil, let node = node {
                setupDoorAnimationPlayer(for: node, initialState: nil, doorType: doorType)
            }
            
            let shouldBeOpen = newState == .open || newState == .ajar
            if shouldBeOpen != isOpen {
                toggleDoor(doorType: doorType)
            }
        }
        
        func toggleDoor(doorType: DoorType) {
            // Get state variables
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
            
            if isAnimating { return }
            guard let player = animationPlayer else { return }
            
            player.stop()
            
            // Set animating flag
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
                
                let timer = Timer.scheduledTimer(withTimeInterval: player.animation.duration + 0.1, repeats: false) { [weak self] _ in
                    if let self = self {
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
                
                let timer = Timer.scheduledTimer(withTimeInterval: player.animation.duration + 0.1, repeats: false) { [weak self] _ in
                    if let self = self {
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
        
        // Configure camera controls
        sceneView.defaultCameraController.interactionMode = .orbitAngleMapping
        sceneView.defaultCameraController.target = SCNVector3Zero
        sceneView.defaultCameraController.maximumVerticalAngle = 0
        sceneView.defaultCameraController.minimumVerticalAngle = 0
        sceneView.defaultCameraController.inertiaEnabled = true
        sceneView.defaultCameraController.inertiaFriction = 0.1
        
        // Load the scene
        if let sceneURL = Bundle.main.url(forResource: "Sapphire", withExtension: "scn"),
           let scene = try? SCNScene(url: sceneURL, options: [
               SCNSceneSource.LoadingOption.animationImportPolicy: SCNSceneSource.AnimationImportPolicy.doNotPlay
           ]) {
            sceneView.scene = scene
            
            // Set scene background to clear
            scene.background.contents = UIColor.clear
            
            // Stop all animations in the scene
            scene.rootNode.enumerateChildNodes { node, _ in
                node.animationKeys.forEach { key in
                    if let player = node.animationPlayer(forKey: key) {
                        player.stop()
                    }
                }
            }
            
            // Configure lighting
            sceneView.autoenablesDefaultLighting = true
            sceneView.allowsCameraControl = true
            sceneView.rendersContinuously = true
            
            // Add ambient light
            let ambientLight = SCNNode()
            ambientLight.light = SCNLight()
            ambientLight.light?.type = .ambient
            ambientLight.light?.color = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
            ambientLight.light?.intensity = 300
            scene.rootNode.addChildNode(ambientLight)
            
            // Add directional light
            let directionalLight = SCNNode()
            directionalLight.light = SCNLight()
            directionalLight.light?.type = .directional
            directionalLight.light?.color = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
            directionalLight.light?.intensity = 800
            directionalLight.light?.castsShadow = true
            directionalLight.light?.shadowRadius = 8.0
            directionalLight.light?.shadowSampleCount = 16
            directionalLight.light?.shadowMode = .deferred
            directionalLight.light?.shadowBias = 0.005
            directionalLight.light?.shadowColor = UIColor(white: 0, alpha: 0.3)
            directionalLight.position = SCNVector3(x: 5, y: 5, z: 5)
            directionalLight.eulerAngles = SCNVector3(x: -Float.pi/4, y: Float.pi/4, z: 0)
            scene.rootNode.addChildNode(directionalLight)
            
            // Set up camera
            if let cameraNode = scene.rootNode.childNode(withName: "camera_default", recursively: true) {
                context.coordinator.storeInitialCameraState(cameraNode)
                sceneView.pointOfView = cameraNode
            } else {
                Logger.vehicle.error("Could not find defaultCamera, using default camera")
                let camera = SCNCamera()
                let cameraNode = SCNNode()
                cameraNode.camera = camera
                cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
                scene.rootNode.addChildNode(cameraNode)
                sceneView.pointOfView = cameraNode
                context.coordinator.storeInitialCameraState(cameraNode)
            }
            
            // Find and set up all animated nodes
            context.coordinator.findChargePortNode(in: scene)
            context.coordinator.findFrunkNode(in: scene)
            context.coordinator.findTrunkNode(in: scene)
            context.coordinator.findDoorNodes(in: scene)
            
            // Set initial states
            let chargePortState = model.chargePortClosureState
            if let node = context.coordinator.chargePortNode,
               let player = node.animationPlayer(forKey: node.animationKeys.first ?? "") {
                player.stop()
                player.speed = 1
                if chargePortState == .open || chargePortState == .ajar {
                    player.animation.timeOffset = 0
                    player.play()
                    let timer = Timer.scheduledTimer(withTimeInterval: player.animation.duration + 0.1, repeats: false) { _ in
                        context.coordinator.isChargePortOpen = true
                        isSceneLoaded = true
                    }
                    context.coordinator.animationTimer = timer
                } else {
                    player.animation.timeOffset = 0
                    context.coordinator.isChargePortOpen = false
                    player.play()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isSceneLoaded = true
                    }
                }
            }
            
            // Set initial frunk state
            if let frunkState = model.frunkClosureState {
                context.coordinator.handleFrunkStateChange(frunkState)
            }
            
            // Set initial trunk state
            if let trunkState = model.trunkClosureState {
                context.coordinator.handleTrunkStateChange(trunkState)
            }
            
            // Set initial door states
            context.coordinator.handleDoorStateChange(model.frontLeftDoorClosureState, doorType: .frontLeft)
            context.coordinator.handleDoorStateChange(model.frontRightDoorClosureState, doorType: .frontRight)
            context.coordinator.handleDoorStateChange(model.rearLeftDoorClosureState, doorType: .rearLeft)
            context.coordinator.handleDoorStateChange(model.rearRightDoorClosureState, doorType: .rearRight)
            
        } else {
            Logger.vehicle.error("Failed to load Sapphire scene")
        }
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        if shouldResetCamera && !context.coordinator.isResetting {
            if let cameraNode = uiView.pointOfView {
                context.coordinator.resetCamera(cameraNode, in: uiView)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    shouldResetCamera = false
                }
            } else {
                print("Failed to reset camera - no camera node found")
                shouldResetCamera = false
            }
        }
        
        // Handle state changes for all animated components
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
