import SwiftUI
import SceneKit
import OSLog

struct SceneKitViewGravity: UIViewRepresentable {
    @Binding var showPlatinum: Bool
    @Binding var carPaintColor: PaintColor
    @Binding var selectedWheel: Wheels
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
            if let node = scene.rootNode.childNode(withName: "ChargeDoor_Pivot", recursively: true) {
                print("✅ Found charge port node by name: \(node.name ?? "unnamed")")
                chargePortNode = node
                setupAnimationPlayer(for: node, initialState: nil)
            } else {
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
                player.animation.repeatCount = 0
                player.animation.autoreverses = false
                
                // Set the initial state
                if let state = initialState {
                    if state == .open || state == .ajar {
                        player.stop()
                        player.speed = 1
                        player.animation.timeOffset = player.animation.duration
                        isChargePortOpen = true
                        
                        player.play()
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                            player.stop()
                        }
                        animationTimer = timer
                    } else {
                        player.stop()
                        player.speed = 1
                        player.animation.timeOffset = 0
                        isChargePortOpen = false
                        
                        player.play()
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                            player.stop()
                        }
                        animationTimer = timer
                    }
                } else {
                    player.stop()
                    player.speed = 1
                    player.animation.timeOffset = 0
                    isChargePortOpen = false
                    
                    player.play()
                    let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                        player.stop()
                    }
                    animationTimer = timer
                }
            }
        }
        
        func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
            isAnimating = false
        }
        
        func animationDidStart(_ anim: CAAnimation) {
            isAnimating = true
        }
        
        func handleChargePortStateChange(_ newState: DoorState) {
            if isAnimating {
                return
            }
            
            if animationPlayer == nil {
                if let node = chargePortNode {
                    setupAnimationPlayer(for: node, initialState: nil)
                } else {
                    print("❌ Cannot reinitialize - charge port node is nil")
                    return
                }
            }
            
            let shouldBeOpen = newState == .open || newState == .ajar
            
            if shouldBeOpen != isChargePortOpen {
                toggleChargePort()
            }
        }
        
        func toggleChargePort() {
            if isAnimating {
                return
            }
            
            guard let player = animationPlayer else {
                return
            }
            
            player.stop()
            isAnimating = true
            
            if isChargePortOpen {
                player.speed = -1
                player.animation.timeOffset = 0
                
                let timer = Timer.scheduledTimer(withTimeInterval: player.animation.duration + 0.1, repeats: false) { [weak self] _ in
                    if let self = self {
                        self.isAnimating = false
                        self.isChargePortOpen = false
                    }
                }
                animationTimer = timer
                
                player.play()
            } else {
                player.speed = 1
                player.animation.timeOffset = 0
                
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
            if let node = scene.rootNode.childNode(withName: "Frunk_Bonnet_Animation", recursively: true) {
                frunkNode = node
                setupFrunkAnimationPlayer(for: node, initialState: nil)
            } else {
                print("❌ Could not find frunk node")
            }
        }
        
        func setupFrunkAnimationPlayer(for node: SCNNode, initialState: DoorState?) {
            guard let key = node.animationKeys.first else {
                print("❌ No animation keys found for frunk node")
                return
            }
            
            if let existingPlayer = frunkAnimationPlayer {
                existingPlayer.stop()
                frunkAnimationPlayer = nil
            }
            
            node.animationKeys.forEach { key in
                if let player = node.animationPlayer(forKey: key) {
                    player.stop()
                }
            }
            
            if let player = node.animationPlayer(forKey: key) {
                self.frunkAnimationPlayer = player
                
                player.animation.isRemovedOnCompletion = false
                player.animation.repeatCount = 0
                player.animation.autoreverses = false
                
                if let state = initialState {
                    if state == .open || state == .ajar {
                        player.stop()
                        player.speed = 1
                        player.animation.timeOffset = player.animation.duration
                        isFrunkOpen = true
                        
                        player.play()
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                            player.stop()
                        }
                        frunkAnimationTimer = timer
                    } else {
                        player.stop()
                        player.speed = 1
                        player.animation.timeOffset = 0
                        isFrunkOpen = false
                        
                        player.play()
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                            player.stop()
                        }
                        frunkAnimationTimer = timer
                    }
                } else {
                    player.stop()
                    player.speed = 1
                    player.animation.timeOffset = 0
                    isFrunkOpen = false
                    
                    player.play()
                    let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                        player.stop()
                    }
                    frunkAnimationTimer = timer
                }
            }
        }
        
        func handleFrunkStateChange(_ newState: DoorState) {
            if isFrunkAnimating {
                return
            }
            
            if frunkAnimationPlayer == nil {
                if let node = frunkNode {
                    setupFrunkAnimationPlayer(for: node, initialState: nil)
                } else {
                    return
                }
            }
            
            let shouldBeOpen = newState == .open || newState == .ajar
            
            if shouldBeOpen != isFrunkOpen {
                toggleFrunk()
            }
        }
        
        func toggleFrunk() {
            if isFrunkAnimating {
                return
            }
            
            guard let player = frunkAnimationPlayer else {
                print("❌ Cannot toggle frunk - animation player missing")
                return
            }
            
            player.stop()
            isFrunkAnimating = true
            
            if isFrunkOpen {
                player.speed = -1
                player.animation.timeOffset = 0
                
                let timer = Timer.scheduledTimer(withTimeInterval: player.animation.duration + 0.1, repeats: false) { [weak self] _ in
                    if let self = self {
                        self.isFrunkAnimating = false
                        self.isFrunkOpen = false
                    }
                }
                frunkAnimationTimer = timer
                
                player.play()
            } else {
                player.speed = 1
                player.animation.timeOffset = 0
                
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
            if let node = scene.rootNode.childNode(withName: "Trunk_Lid_Animation", recursively: true) {
                trunkNode = node
                setupTrunkAnimationPlayer(for: node, initialState: nil)
            } else {
                print("❌ Could not find trunk node")
            }
        }
        
        func setupTrunkAnimationPlayer(for node: SCNNode, initialState: DoorState?) {
            guard let key = node.animationKeys.first else {
                print("❌ No animation keys found for trunk node")
                return
            }
            
            if let existingPlayer = trunkAnimationPlayer {
                existingPlayer.stop()
                trunkAnimationPlayer = nil
            }
            
            node.animationKeys.forEach { key in
                if let player = node.animationPlayer(forKey: key) {
                    player.stop()
                }
            }
            
            if let player = node.animationPlayer(forKey: key) {
                self.trunkAnimationPlayer = player
                
                player.animation.isRemovedOnCompletion = false
                player.animation.repeatCount = 0
                player.animation.autoreverses = false
                
                if let state = initialState {
                    if state == .open || state == .ajar {
                        player.stop()
                        player.speed = 1
                        player.animation.timeOffset = player.animation.duration
                        isTrunkOpen = true
                        
                        player.play()
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                            player.stop()
                        }
                        trunkAnimationTimer = timer
                    } else {
                        player.stop()
                        player.speed = 1
                        player.animation.timeOffset = 0
                        isTrunkOpen = false
                        
                        player.play()
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                            player.stop()
                        }
                        trunkAnimationTimer = timer
                    }
                } else {
                    player.stop()
                    player.speed = 1
                    player.animation.timeOffset = 0
                    isTrunkOpen = false
                    
                    player.play()
                    let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                        player.stop()
                    }
                    trunkAnimationTimer = timer
                }
            }
        }
        
        func handleTrunkStateChange(_ newState: DoorState) {
            if isTrunkAnimating {
                return
            }
            
            if trunkAnimationPlayer == nil {
                if let node = trunkNode {
                    setupTrunkAnimationPlayer(for: node, initialState: nil)
                } else {
                    return
                }
            }
            
            let shouldBeOpen = newState == .open || newState == .ajar
            
            if shouldBeOpen != isTrunkOpen {
                toggleTrunk()
            }
        }
        
        func toggleTrunk() {
            if isTrunkAnimating {
                return
            }
            
            guard let player = trunkAnimationPlayer else {
                return
            }
            
            player.stop()
            isTrunkAnimating = true
            
            if isTrunkOpen {
                player.speed = -1
                player.animation.timeOffset = 0
                
                let timer = Timer.scheduledTimer(withTimeInterval: player.animation.duration + 0.1, repeats: false) { [weak self] _ in
                    if let self = self {
                        self.isTrunkAnimating = false
                        self.isTrunkOpen = false
                    }
                }
                trunkAnimationTimer = timer
                
                player.play()
            } else {
                player.speed = 1
                player.animation.timeOffset = 0
                
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
        
        enum DoorType {
            case frontLeft
            case frontRight
            case rearLeft
            case rearRight
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
            
            if let existingPlayer = animationPlayer {
                existingPlayer.stop()
                animationPlayer = nil
            }
            
            node.animationKeys.forEach { key in
                if let player = node.animationPlayer(forKey: key) {
                    player.stop()
                }
            }
            
            if let player = node.animationPlayer(forKey: key) {
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
                
                player.animation.isRemovedOnCompletion = false
                player.animation.repeatCount = 0
                player.animation.autoreverses = false
                
                if let state = initialState {
                    if state == .open || state == .ajar {
                        player.stop()
                        player.speed = 1
                        player.animation.timeOffset = player.animation.duration
                        
                        switch doorType {
                        case .frontLeft: self.isFrontLeftDoorOpen = true
                        case .frontRight: self.isFrontRightDoorOpen = true
                        case .rearLeft: self.isRearLeftDoorOpen = true
                        case .rearRight: self.isRearRightDoorOpen = true
                        }
                        
                        player.play()
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                            player.stop()
                        }
                        
                        switch doorType {
                        case .frontLeft: self.frontLeftDoorAnimationTimer = timer
                        case .frontRight: self.frontRightDoorAnimationTimer = timer
                        case .rearLeft: self.rearLeftDoorAnimationTimer = timer
                        case .rearRight: self.rearRightDoorAnimationTimer = timer
                        }
                    } else {
                        player.stop()
                        player.speed = 1
                        player.animation.timeOffset = 0
                        
                        switch doorType {
                        case .frontLeft: self.isFrontLeftDoorOpen = false
                        case .frontRight: self.isFrontRightDoorOpen = false
                        case .rearLeft: self.isRearLeftDoorOpen = false
                        case .rearRight: self.isRearRightDoorOpen = false
                        }
                        
                        player.play()
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                            player.stop()
                        }
                        
                        switch doorType {
                        case .frontLeft: self.frontLeftDoorAnimationTimer = timer
                        case .frontRight: self.frontRightDoorAnimationTimer = timer
                        case .rearLeft: self.rearLeftDoorAnimationTimer = timer
                        case .rearRight: self.rearRightDoorAnimationTimer = timer
                        }
                    }
                } else {
                    player.stop()
                    player.speed = 1
                    player.animation.timeOffset = 0
                    
                    switch doorType {
                    case .frontLeft: self.isFrontLeftDoorOpen = false
                    case .frontRight: self.isFrontRightDoorOpen = false
                    case .rearLeft: self.isRearLeftDoorOpen = false
                    case .rearRight: self.isRearRightDoorOpen = false
                    }
                    
                    player.play()
                    let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                        player.stop()
                    }
                    
                    switch doorType {
                    case .frontLeft: self.frontLeftDoorAnimationTimer = timer
                    case .frontRight: self.frontRightDoorAnimationTimer = timer
                    case .rearLeft: self.rearLeftDoorAnimationTimer = timer
                    case .rearRight: self.rearRightDoorAnimationTimer = timer
                    }
                }
            }
        }
        
        func handleDoorStateChange(_ newState: DoorState, doorType: DoorType) {
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
            
            if isAnimating {
                return
            }
            
            if animationPlayer == nil {
                if let node = node {
                    setupDoorAnimationPlayer(for: node, initialState: nil, doorType: doorType)
                } else {
                    print("❌ Cannot reinitialize - door node is nil")
                    return
                }
            }
            
            let shouldBeOpen = newState == .open || newState == .ajar
            
            if shouldBeOpen != isOpen {
                toggleDoor(doorType: doorType)
            }
        }
        
        func toggleDoor(doorType: DoorType) {
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
            
            if isAnimating {
                return
            }
            
            guard let player = animationPlayer else {
                return
            }
            
            player.stop()
            
            switch doorType {
            case .frontLeft: isFrontLeftDoorAnimating = true
            case .frontRight: isFrontRightDoorAnimating = true
            case .rearLeft: isRearLeftDoorAnimating = true
            case .rearRight: isRearRightDoorAnimating = true
            }
            
            if isOpen {
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
        if let sceneURL = Bundle.main.url(forResource: "Gravity", withExtension: "scn"),
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
            
            // Set initial visibility
            updateNodeVisibility(in: scene, showPlatinum: showPlatinum)
            
            // Update paint material
            updateCarPaintMaterial(in: scene, color: carPaintColor.color)
            
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
            
            // Find and set up animation nodes
            context.coordinator.findChargePortNode(in: scene)
            context.coordinator.findFrunkNode(in: scene)
            context.coordinator.findTrunkNode(in: scene)
            context.coordinator.findDoorNodes(in: scene)
            
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
            Logger.vehicle.error("Failed to load Gravity scene")
        }
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        if let scene = uiView.scene {
            updateNodeVisibility(in: scene, showPlatinum: showPlatinum)
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
    
    private func updateNodeVisibility(in scene: SCNScene, showPlatinum: Bool) {
        let materialNames = [
            "Stealth_Platinum_ext_cantrail",
            "Stealth_Platinum_ext_rim_outside",
            "bonnet_switch"
        ]
        
        let targetColor = showPlatinum ? "#CCCCCC" : "#4E4E4E"
        guard let color = Color(hex: targetColor) else { return }
        let uiColor = UIColor(color)
        
        scene.rootNode.enumerateChildNodes { node, _ in
            if let materials = node.geometry?.materials {
                for material in materials {
                    if let materialName = material.name,
                       materialNames.contains(materialName) {
                        material.diffuse.contents = uiColor
                    }
                }
            }
        }
    }
    
    private func updateCarPaintMaterial(in scene: SCNScene, color: Color) {
        let uiColor = UIColor(color)
        
        scene.rootNode.enumerateChildNodes { node, _ in
            if let materials = node.geometry?.materials {
                for material in materials {
                    if material.name?.lowercased() == "car_paint" {
                        material.diffuse.contents = uiColor
                    }
                }
            }
        }
    }
    
    private func updateWheelVisibility(in scene: SCNScene, selectedWheel: String?) {
        // First try to find nodes for the selected wheel
        let parentWheelNodes = scene.rootNode.childNodes(passingTest: { node, _ in
            guard let nodeName = node.name else { return false }
            return nodeName.hasPrefix("Wheel_Set") && 
                   !nodeName.contains("_01_") && 
                   !nodeName.contains("_02_") && 
                   !nodeName.contains("_03_") && 
                   !nodeName.contains("_04_")
        })
        
        // Check if we found any nodes for the selected wheel
        let foundSelectedWheel = parentWheelNodes.contains { node in
            guard let nodeName = node.name else { return false }
            return nodeName == selectedWheel
        }
        
        // If no nodes found for selected wheel, try to find Aether wheels
        if !foundSelectedWheel {
            let aetherWheelNodes = scene.rootNode.childNodes(passingTest: { node, _ in
                guard let nodeName = node.name else { return false }
                return nodeName.hasPrefix("Wheel_Set") && 
                       nodeName.contains("Aether") &&
                       !nodeName.contains("_01_") && 
                       !nodeName.contains("_02_") && 
                       !nodeName.contains("_03_") && 
                       !nodeName.contains("_04_")
            })
            
            // If we found Aether wheels, use those instead
            if !aetherWheelNodes.isEmpty {
                // Hide all wheel nodes first
                parentWheelNodes.forEach { node in
                    node.isHidden = true
                }
                
                // Show only Aether wheels
                aetherWheelNodes.forEach { node in
                    node.isHidden = false
                }
                return
            }
        }
        
        // If we either found the selected wheel or no Aether wheels, proceed with normal visibility update
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
