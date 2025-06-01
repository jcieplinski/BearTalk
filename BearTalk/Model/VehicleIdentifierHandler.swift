//
//  VehicleIdentifierHandler.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/22/25.
//

import SwiftUI
import SwiftData
import OSLog
import SceneKit

@ModelActor
actor VehicleIdentifierHandler {
    public func fetch() throws -> [VehicleIdentifierEntity] {
        let descriptor = FetchDescriptor<VehicleIdentifier>()
        let fetchedVehicles = try modelContext.fetch(descriptor).sorted{ $0.nickname < $1.nickname }
        
        return fetchedVehicles.map(VehicleIdentifierEntity.init)
    }
    
    public func delete(_ vehicles: [VehicleIdentifierEntity]) async throws {
        let descriptor = FetchDescriptor<VehicleIdentifier>()
        let fetchedVehicles = try modelContext.fetch(descriptor)
        
        let toDelete = fetchedVehicles.filter { vehicles.map(\.id).contains($0.id)}
        
        toDelete.forEach { vehicle in
            modelContext.delete(vehicle)
        }
    }
    
    public func update(_ vehicles: [VehicleIdentifierEntity]) async throws {
        let descriptor = FetchDescriptor<VehicleIdentifier>()
        let fetchedVehicles = try modelContext.fetch(descriptor)
        
        try fetchedVehicles.forEach { vehicle in
            if let updated = vehicles.first(where: { $0.id == vehicle.id }),
               updated.nickname != vehicle.nickname {
                vehicle.nickname = updated.nickname
                try modelContext.save()
            }
        }
    }
    
    public func add(_ vehicles: [VehicleIdentifierEntity]) async throws {
        let existing = try fetch()
        
        let nonExistingVehicles = vehicles.filter { !existing.map { $0.id }.contains($0.id) }
        let expiredVehicles = existing.filter { !vehicles.map(\.self.id).contains($0.id) }
        
        try nonExistingVehicles.forEach { entity in
            let vehicle = VehicleIdentifier(id: entity.id, nickname: entity.nickname)
            modelContext.insert(vehicle)
            try modelContext.save()
        }
        
        try await delete(expiredVehicles)
        try await update(vehicles)
    }
    
    public func fetchSnapshotData(for vehicleId: String) async throws -> Data? {
        let descriptor = FetchDescriptor<VehicleIdentifier>(predicate: #Predicate<VehicleIdentifier> { identifier in
            identifier.id == vehicleId
        })
        let vehicle = try modelContext.fetch(descriptor).first
        return vehicle?.snapshotData
    }
    
    public func takeAndSaveSnapshot(for vehicle: Vehicle) async throws {
        // Skip if we already have a snapshot
        let descriptor = FetchDescriptor<VehicleIdentifier>(predicate: #Predicate<VehicleIdentifier> { identifier in
            identifier.id == vehicle.vehicleId
        })
        
        // Create a temporary SceneKit view
        let sceneView = await SCNView(frame: CGRect(x: 0, y: 0, width: 800, height: 400))
        
        // Configure view on main actor
        await MainActor.run {
            sceneView.backgroundColor = .clear
            sceneView.autoenablesDefaultLighting = true
            sceneView.rendersContinuously = true
            sceneView.preferredFramesPerSecond = 60
            sceneView.antialiasingMode = .multisampling4X
            sceneView.isOpaque = false
            sceneView.allowsCameraControl = false
        }
        
        // Load the appropriate scene based on the vehicle model
        var scene: SCNScene?
        let sceneName: String
        
        // Determine which scene to load based on the vehicle model
        switch vehicle.vehicleConfig.model {
        case .air:
            if vehicle.vehicleConfig.modelVariant == .sapphire {
                sceneName = "Sapphire"
            } else {
                sceneName = "Air"
            }
        case .gravity:
            sceneName = "Gravity"
        default:
            sceneName = "Air"
        }
        
        if let sceneURL = Bundle.main.url(forResource: sceneName, withExtension: "scn") {
            do {
                scene = try SCNScene(url: sceneURL, options: [
                    SCNSceneSource.LoadingOption.animationImportPolicy: SCNSceneSource.AnimationImportPolicy.doNotPlay,
                    .checkConsistency: false,
                    .flattenScene: false
                ])
            } catch {
                print("Error loading scene: \(error)")
                throw error
            }
        }
        
        if let loadedScene = scene {
            var cameraNode: SCNNode?
            
            // Configure scene on main actor
            await MainActor.run {
                sceneView.scene = loadedScene
                loadedScene.background.contents = UIColor.clear
                loadedScene.fogStartDistance = 0
                loadedScene.fogEndDistance = 0
                loadedScene.fogDensityExponent = 0
                
                // Stop all animations in the scene
                loadedScene.rootNode.enumerateChildNodes { node, _ in
                    node.animationKeys.forEach { key in
                        if let player = node.animationPlayer(forKey: key) {
                            player.stop()
                        }
                    }
                }
                
                // Add ambient light
                let ambientLight = SCNNode()
                ambientLight.light = SCNLight()
                ambientLight.light?.type = .ambient
                ambientLight.light?.color = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
                ambientLight.light?.intensity = 300
                loadedScene.rootNode.addChildNode(ambientLight)
                
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
                loadedScene.rootNode.addChildNode(directionalLight)
                
                // Find and set the opening camera
                if let foundCameraNode = loadedScene.rootNode.childNode(withName: "camera_opening", recursively: true) {
                    print("Found opening camera node")
                    cameraNode = foundCameraNode
                    sceneView.pointOfView = foundCameraNode
                    // Ensure camera doesn't affect background
                    foundCameraNode.camera?.wantsHDR = false
                    foundCameraNode.camera?.wantsExposureAdaptation = false
                } else {
                    print("Could not find opening camera, using default camera")
                    let camera = SCNCamera()
                    camera.wantsHDR = false
                    camera.wantsExposureAdaptation = false
                    let newCameraNode = SCNNode()
                    newCameraNode.camera = camera
                    newCameraNode.position = SCNVector3(x: 0, y: 2.5, z: 4.5)
                    newCameraNode.eulerAngles = SCNVector3(x: -Float.pi/6, y: 0, z: 0)
                    loadedScene.rootNode.addChildNode(newCameraNode)
                    cameraNode = newCameraNode
                    sceneView.pointOfView = newCameraNode
                }
            }
            
            // Update materials based on vehicle config
            await updateSnapshotMaterials(in: loadedScene, vehicle: vehicle)
            
            // Ensure the scene is rendered
            await MainActor.run {
                sceneView.layoutIfNeeded()
                sceneView.setNeedsDisplay()
            }
            
            // Wait for the scene to be ready
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            
            // Take the snapshot with transparency
            let renderer = await MainActor.run { () -> SCNRenderer in
                let renderer = SCNRenderer(device: MTLCreateSystemDefaultDevice(), options: nil)
                renderer.scene = loadedScene
                renderer.autoenablesDefaultLighting = true
                
                // Set the renderer's camera to match the scene view's camera
                if let camera = cameraNode {
                    renderer.pointOfView = camera
                }
                
                return renderer
            }
            
            let size = CGSize(width: 800, height: 400)
            let image = await MainActor.run {
                renderer.snapshot(atTime: 0, with: size, antialiasingMode: .multisampling4X)
            }
            
            // Convert to data and store in SwiftData
            // Use PNG format to preserve transparency
            if let imageData = image.pngData() {
                if let vehicleIdentifier = try modelContext.fetch(descriptor).first {
                    vehicleIdentifier.snapshotData = imageData
                    try modelContext.save()
                }
            }
        }
    }
    
    private func updateSnapshotMaterials(in scene: SCNScene, vehicle: Vehicle) async {
        await MainActor.run {
            print("Updating materials for vehicle: \(vehicle.vehicleConfig.model) \(vehicle.vehicleConfig.modelVariant)")
            print("Roof configuration: \(vehicle.vehicleConfig.roof)")
            print("Look configuration: \(vehicle.vehicleConfig.look)")
            
            // Update car paint color
            let paintUIColor = UIColor(vehicle.vehicleConfig.paintColor.color)
            scene.rootNode.enumerateChildNodes { node, _ in
                if let geometry = node.geometry {
                    for material in geometry.materials {
                        if let materialName = material.name?.lowercased() {
                            if materialName.contains("carpaint") || materialName.contains("car_paint") {
                                material.diffuse.contents = paintUIColor
                            }
                        }
                    }
                }
            }
            
            // Update wheel visibility
            let wheelNodeName = vehicle.vehicleConfig.wheels.nodeTitle
            scene.rootNode.enumerateChildNodes { node, _ in
                if let nodeName = node.name {
                    if vehicle.vehicleConfig.model == .gravity {
                        if nodeName.hasPrefix("Wheel_Set") && 
                           !nodeName.contains("_01_") && 
                           !nodeName.contains("_02_") && 
                           !nodeName.contains("_03_") && 
                           !nodeName.contains("_04_") {
                            node.isHidden = nodeName != wheelNodeName
                        }
                    } else {
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
            
            // Update platinum/stealth visibility
            let showPlatinum = vehicle.vehicleConfig.look != .stealth && vehicle.vehicleConfig.look != .sapphire
            let showGlassRoof = vehicle.vehicleConfig.roof == .glassCanopy
            
            print("Show platinum: \(showPlatinum)")
            print("Show glass roof: \(showGlassRoof)")
            
            // First pass: Log all roof-related nodes
            var roofNodes: [(node: SCNNode, name: String, type: String)] = []
            scene.rootNode.enumerateChildNodes { node, _ in
                if let nodeName = node.name?.lowercased() {
                    if nodeName.contains("glassroof") || nodeName.contains("metalroof") {
                        let type: String
                        if nodeName.contains("glassroof") {
                            type = "glassroof"
                        } else if nodeName.contains("metalroof") {
                            type = "metalroof"
                        } else {
                            return
                        }
                        roofNodes.append((node: node, name: nodeName, type: type))
                        print("Found roof node: \(nodeName), type: \(type), currently hidden: \(node.isHidden)")
                    }
                }
            }
            
            // Second pass: Update visibility based on node type and configuration
            for (node, nodeName, type) in roofNodes {
                let shouldBeHidden: Bool
                
                switch type {
                case "glassroof":
                    shouldBeHidden = !showGlassRoof
                case "metalroof":
                    shouldBeHidden = showGlassRoof
                default:
                    continue
                }
                
                // Additional visibility rules based on look
                if nodeName.contains("platinum") {
                    node.isHidden = shouldBeHidden || !showPlatinum
                } else if nodeName.contains("stealth") {
                    node.isHidden = shouldBeHidden || showPlatinum
                } else {
                    node.isHidden = shouldBeHidden
                }
                
                print("Setting \(type) node '\(nodeName)' hidden: \(node.isHidden)")
            }
            
            // Update other look-specific nodes (not roof-related)
            scene.rootNode.enumerateChildNodes { node, _ in
                if let nodeName = node.name?.lowercased() {
                    // Skip roof nodes as they were handled above
                    if nodeName.contains("glassroof") || nodeName.contains("metalroof") {
                        return
                    }
                    
                    if nodeName.contains("platinum") {
                        node.isHidden = !showPlatinum
                        print("Setting platinum node '\(nodeName)' hidden: \(node.isHidden)")
                    }
                    if nodeName.contains("stealth") {
                        node.isHidden = showPlatinum
                        print("Setting stealth node '\(nodeName)' hidden: \(node.isHidden)")
                    }
                }
            }
            
            // Verify final state
            scene.rootNode.enumerateChildNodes { node, _ in
                if let nodeName = node.name?.lowercased() {
                    if nodeName.contains("glassroof") || nodeName.contains("metalroof") ||
                       nodeName.contains("platinum") || nodeName.contains("stealth") {
                        print("Final state - node: \(nodeName), hidden: \(node.isHidden)")
                    }
                }
            }
        }
    }
}
