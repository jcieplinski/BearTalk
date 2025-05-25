import SwiftUI
import SceneKit
import OSLog

struct SceneKitViewSapphire: UIViewRepresentable {
    @Binding var shouldResetCamera: Bool
    @Binding var isSceneLoaded: Bool
    let onViewCreated: (SCNView) -> Void
    
    // Add Coordinator
    final class Coordinator {
        var initialCameraNode: SCNNode?
        var initialCameraTransform: SCNMatrix4?
        var initialCameraOrientation: SCNQuaternion?
        var initialCameraPosition: SCNVector3?
        var initialCameraFOV: CGFloat?
        var initialLookAtPoint: SCNVector3?
        var isResetting = false
        var sceneView: SCNView?
        
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
           let scene = try? SCNScene(url: sceneURL, options: nil) {
            sceneView.scene = scene
            
            // Set scene background to clear
            scene.background.contents = UIColor.clear
            scene.isPaused = true  // Keep scene paused
            
            // Configure lighting
            sceneView.autoenablesDefaultLighting = true
            sceneView.allowsCameraControl = true
            
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
            
            // Mark scene as loaded after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isSceneLoaded = true
            }
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
    }
} 
