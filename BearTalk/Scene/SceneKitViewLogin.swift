//
//  SceneKitViewLogin.swift
//  SceneTest
//
//  Created by Joe Cieplinski on 5/18/25.
//

import SwiftUI
import SceneKit

struct SceneKitViewLogin: UIViewRepresentable {
    let onViewCreated: (SCNView) -> Void
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.tag = 1  // Add tag for snapshot capture
        
        // Disable all camera controls
        sceneView.allowsCameraControl = false
        
        // Try multiple approaches to load the scene
        var scene: SCNScene?
        
        // Approach 1: Try loading directly from the main bundle
        if let sceneURL = Bundle.main.url(forResource: "Air", withExtension: "scn") {
            do {
                scene = try SCNScene(url: sceneURL, options: nil)
            } catch {
                print("Error loading scene from URL: \(error)")
            }
        } else {
            print("Could not find scene file in bundle")
            
            // Approach 2: Try loading from the main bundle without subdirectory
            if let sceneURL = Bundle.main.url(forResource: "Lucid3D96", withExtension: "scn") {
                do {
                    scene = try SCNScene(url: sceneURL, options: nil)
                } catch {
                    print("Error loading scene at root URL: \(error)")
                }
            } else {
                print("Could not find scene file at root level")
            }
        }
        
        // If we have a scene, set it up
        if let loadedScene = scene { 
            sceneView.scene = loadedScene
            
            // Set scene background to clear
            loadedScene.background.contents = UIColor.clear
            
            // Configure lighting
            sceneView.autoenablesDefaultLighting = true
            sceneView.backgroundColor = .clear
            
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
            updateNodeVisibility(in: loadedScene, showPlatinum: true, showGlassRoof: true)
            
            // Update carpaint material with initial color
            updateCarPaintMaterial(in: loadedScene, color: PaintColor.stellarWhite.color)
            
            // Try to find the interactive camera
            if let cameraNode = loadedScene.rootNode.childNode(withName: "camera_interactive", recursively: true) {
                // Set as point of view
                sceneView.pointOfView = cameraNode
            } else {
                print("Could not find camera_interactive, using default camera")
                // Create a default camera if we can't find the one in the scene
                let camera = SCNCamera()
                let cameraNode = SCNNode()
                cameraNode.camera = camera
                cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
                loadedScene.rootNode.addChildNode(cameraNode)
                sceneView.pointOfView = cameraNode
            }
            
            // Call the callback
            onViewCreated(sceneView)
        } else {
            print("Failed to load scene using all available methods")
        }
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = .clear
        if let loadedScene = scene {
            loadedScene.isPaused = true  // Pause the scene instead of the view
        }
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        if let scene = uiView.scene {
            updateNodeVisibility(in: scene, showPlatinum: true, showGlassRoof: true)
            updateCarPaintMaterial(in: scene, color: PaintColor.stellarWhite.color)
            updateWheelVisibility(in: scene, selectedWheel: Wheels.dream.nodeTitle)
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
