import SwiftUI
import SceneKit

struct SceneKitViewSapphire: UIViewRepresentable {
    @Binding var shouldResetCamera: Bool
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
        sceneView.tag = 3  // Add tag for snapshot capture
        
        // Store the reference in the coordinator
        context.coordinator.sceneView = sceneView
        
        // Call the callback
        onViewCreated(sceneView)
        
        sceneView.defaultCameraController.interactionMode = .orbitAngleMapping
        sceneView.defaultCameraController.target = SCNVector3Zero
        sceneView.defaultCameraController.maximumVerticalAngle = 0
        sceneView.defaultCameraController.minimumVerticalAngle = 0
        sceneView.defaultCameraController.inertiaEnabled = true
        
        var scene: SCNScene?
        
        if let sceneURL = Bundle.main.url(forResource: "Sapphire", withExtension: "scn") {
            do {
                scene = try SCNScene(url: sceneURL, options: nil)
            } catch {
                print("Error loading scene from URL: \(error)")
            }
        }
        
        if let loadedScene = scene {
            sceneView.scene = loadedScene
            loadedScene.background.contents = UIColor.clear
            
            sceneView.autoenablesDefaultLighting = true
            sceneView.allowsCameraControl = true
            sceneView.backgroundColor = .clear
            
            let ambientLight = SCNNode()
            ambientLight.light = SCNLight()
            ambientLight.light?.type = .ambient
            ambientLight.light?.color = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
            ambientLight.light?.intensity = 300
            loadedScene.rootNode.addChildNode(ambientLight)
            
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
            loadedScene.rootNode.addChildNode(directionalLight)
            
            if let cameraNode = loadedScene.rootNode.childNode(withName: "camera_default", recursively: true) {
                context.coordinator.storeInitialCameraState(cameraNode)
                sceneView.pointOfView = cameraNode
            } else {
                print("Could not find defaultCamera, using default camera")
                let camera = SCNCamera()
                let cameraNode = SCNNode()
                cameraNode.camera = camera
                cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
                loadedScene.rootNode.addChildNode(cameraNode)
                sceneView.pointOfView = cameraNode
                context.coordinator.storeInitialCameraState(cameraNode)
            }
        }
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        sceneView.backgroundColor = .clear
        if let loadedScene = scene {
            loadedScene.isPaused = true
        }
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
