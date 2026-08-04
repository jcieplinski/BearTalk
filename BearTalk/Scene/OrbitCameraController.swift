//
//  OrbitCameraController.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 8/2/26.
//

import SceneKit
import UIKit
import simd

/// Drives the home-tab car camera with custom gestures instead of SceneKit's
/// `allowsCameraControl`, which cannot reliably restore an exact camera position
/// at launch. Because we own the point-of-view node directly, saving, restoring,
/// and resetting the camera are all exact.
///
/// Interaction model (a turntable/arcball around a `target` point that the camera
/// always looks at, so the car stays centered while orbiting):
/// - One-finger drag orbits horizontally (azimuth) and vertically (elevation),
///   with horizontal spin inertia.
/// - Two-finger drag pans the view (translates camera and target together).
/// - Pinch changes the camera's field of view (zoom).
final class OrbitCameraController: NSObject, UIGestureRecognizerDelegate {
    private weak var sceneView: SCNView?
    private weak var cameraNode: SCNNode?
    private let model: CarSceneModel

    /// Pivot the camera rigidly rotates around (the car's center at the world
    /// origin by default). Shifted by two-finger pans and persisted so a panned
    /// view survives relaunch.
    private var target = simd_float3(0, 0, 0)

    // Default (scene-authored) state, captured before restoring, for reset.
    private let initialPosition: simd_float3
    private let initialOrientation: simd_quatf
    private let initialTransform: simd_float4x4
    private let initialFOV: CGFloat
    private let initialTarget: simd_float3

    // One-finger orbit / inertia
    private var lastOrbitTranslation: CGPoint = .zero
    private var angularVelocity: Float = 0          // azimuth radians per second
    private var inertiaLink: CADisplayLink?

    // Two-finger pan
    private var lastPanTranslation: CGPoint = .zero

    // Pinch
    private var pinchBaseFOV: CGFloat = 0

    // Reset animation
    private var resetLink: CADisplayLink?
    private var resetStartTime: CFTimeInterval = 0
    private var resetFromPosition = simd_float3(0, 0, 0)
    private var resetFromOrientation = simd_quatf()
    private var resetFromFOV: CGFloat = 0
    private var resetFromTarget = simd_float3(0, 0, 0)

    // Change-based persistence
    private var saveTimer: Timer?
    private var lastSavedTransform: simd_float4x4?
    private var lastSavedFOV: CGFloat?

    // Tunables
    private let orbitSensitivity: Float = 0.008     // radians per point dragged
    private let panSensitivity: Float = 1.0         // multiplier on 1:1 finger tracking
    private let inertiaDamping: Float = 0.90        // velocity multiplier per frame
    private let maxAngularVelocity: Float = 5.0     // radians per second
    private let maxElevation: Float = 1.40          // ~80 degrees, keeps away from the poles
    private let minFOV: CGFloat = 12
    private let maxFOV: CGFloat = 80
    private let resetDuration: CFTimeInterval = 0.5

    init(sceneView: SCNView, cameraNode: SCNNode, model: CarSceneModel) {
        self.sceneView = sceneView
        self.cameraNode = cameraNode
        self.model = model

        self.initialPosition = cameraNode.simdPosition
        self.initialOrientation = cameraNode.simdOrientation
        self.initialTransform = cameraNode.simdTransform
        self.initialFOV = cameraNode.camera?.fieldOfView ?? 40
        self.initialTarget = simd_float3(0, 0, 0)

        super.init()

        // We manage the camera ourselves.
        sceneView.allowsCameraControl = false

        // Restore the last user-adjusted view. With camera control off, the
        // point-of-view node's transform renders faithfully, including at launch.
        CameraPersistence.restore(node: cameraNode, for: model)
        target = CameraPersistence.restoreTarget(for: model) ?? simd_float3(0, 0, 0)

        addGestures(to: sceneView)
        lastSavedTransform = cameraNode.simdTransform
        lastSavedFOV = cameraNode.camera?.fieldOfView
        startSaveTimer()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(persistNow),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        inertiaLink?.invalidate()
        resetLink?.invalidate()
        saveTimer?.invalidate()
    }

    // MARK: - Gestures

    private func addGestures(to view: SCNView) {
        let orbit = UIPanGestureRecognizer(target: self, action: #selector(handleOrbit(_:)))
        orbit.maximumNumberOfTouches = 1
        orbit.delegate = self
        view.addGestureRecognizer(orbit)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.minimumNumberOfTouches = 2
        pan.maximumNumberOfTouches = 2
        pan.delegate = self
        view.addGestureRecognizer(pan)

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinch.delegate = self
        view.addGestureRecognizer(pinch)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        // Our own gestures (orbit/pan/pinch) may combine, but never run alongside
        // the enclosing scroll view's pan.
        other !== enclosingScrollView?.panGestureRecognizer
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldBeRequiredToFailBy other: UIGestureRecognizer) -> Bool {
        // Force the scroll view to wait for (and yield to) any car gesture, so
        // touches that land on the car never scroll the page.
        other === enclosingScrollView?.panGestureRecognizer
    }

    private var enclosingScrollView: UIScrollView? {
        var view: UIView? = sceneView?.superview
        while let current = view {
            if let scrollView = current as? UIScrollView {
                return scrollView
            }
            view = current.superview
        }
        return nil
    }

    @objc private func handleOrbit(_ gesture: UIPanGestureRecognizer) {
        guard let view = sceneView else { return }

        switch gesture.state {
        case .began:
            stopInertia()
            stopReset()
            lastOrbitTranslation = gesture.translation(in: view)
        case .changed:
            let t = gesture.translation(in: view)
            let dx = Float(t.x - lastOrbitTranslation.x)
            let dy = Float(t.y - lastOrbitTranslation.y)
            lastOrbitTranslation = t
            applyOrbit(deltaAzimuth: -dx * orbitSensitivity,
                       deltaElevation: -dy * orbitSensitivity)
        case .ended, .cancelled:
            let vx = Float(gesture.velocity(in: view).x)
            angularVelocity = max(-maxAngularVelocity,
                                  min(maxAngularVelocity, -vx * orbitSensitivity))
            if abs(angularVelocity) > 0.05 {
                startInertia()
            } else {
                persistNow()
            }
        default:
            break
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = sceneView, let node = cameraNode else { return }

        switch gesture.state {
        case .began:
            stopInertia()
            stopReset()
            lastPanTranslation = gesture.translation(in: view)
        case .changed:
            let t = gesture.translation(in: view)
            let dx = Float(t.x - lastPanTranslation.x)
            let dy = Float(t.y - lastPanTranslation.y)
            lastPanTranslation = t

            let scale = worldUnitsPerPoint() * panSensitivity
            let right = simd_normalize(node.simdWorldRight)
            let up = simd_normalize(node.simdWorldUp)
            // Drag right moves the car right (camera left); drag down moves it down.
            let delta = right * (-dx * scale) + up * (dy * scale)
            node.simdPosition += delta
            target += delta
        case .ended, .cancelled:
            persistNow()
        default:
            break
        }
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let camera = cameraNode?.camera else { return }

        switch gesture.state {
        case .began:
            stopReset()
            pinchBaseFOV = camera.fieldOfView
        case .changed:
            // Pinch out (scale > 1) zooms in, i.e. reduces field of view.
            let fov = pinchBaseFOV / CGFloat(gesture.scale)
            camera.fieldOfView = min(max(fov, minFOV), maxFOV)
        case .ended, .cancelled:
            persistNow()
        default:
            break
        }
    }

    // MARK: - Orbit math

    /// Rigidly rotates the whole camera about the pivot (`target`, the car's
    /// center), so the car spins in place at its center rather than the camera
    /// circling it like a platform. Horizontal spins about world up; vertical
    /// spins about the camera's (horizontal) right axis, clamped near the poles.
    private func applyOrbit(deltaAzimuth: Float, deltaElevation: Float) {
        guard let node = cameraNode else { return }

        if deltaAzimuth != 0 {
            let rotation = simd_quatf(angle: deltaAzimuth, axis: simd_float3(0, 1, 0))
            node.simdPosition = rotation.act(node.simdPosition - target) + target
            node.simdOrientation = rotation * node.simdOrientation
        }

        if deltaElevation != 0 {
            let forward = simd_normalize(node.simdWorldFront)
            let pitch = asin(max(-1, min(1, forward.y)))
            let clampedPitch = max(-maxElevation, min(maxElevation, pitch + deltaElevation))
            let allowed = clampedPitch - pitch
            if abs(allowed) > 1e-6 {
                let right = simd_normalize(node.simdWorldRight)
                let rotation = simd_quatf(angle: allowed, axis: right)
                node.simdPosition = rotation.act(node.simdPosition - target) + target
                node.simdOrientation = rotation * node.simdOrientation
            }
        }
    }

    /// Approximate world-space distance covered by one screen point at the
    /// target's depth, for 1:1 pan tracking.
    private func worldUnitsPerPoint() -> Float {
        guard let node = cameraNode, let view = sceneView else { return 0 }
        let distance = simd_length(node.simdPosition - target)
        let fov = Float((node.camera?.fieldOfView ?? 40) * .pi / 180)
        let height = Float(max(view.bounds.height, 1))
        return (2 * distance * tan(fov / 2)) / height
    }

    // MARK: - Inertia

    private func startInertia() {
        stopInertia()
        let link = CADisplayLink(target: self, selector: #selector(stepInertia(_:)))
        link.add(to: .main, forMode: .common)
        inertiaLink = link
    }

    private func stopInertia() {
        inertiaLink?.invalidate()
        inertiaLink = nil
    }

    @objc private func stepInertia(_ link: CADisplayLink) {
        applyOrbit(deltaAzimuth: angularVelocity * Float(link.duration), deltaElevation: 0)
        angularVelocity *= inertiaDamping
        if abs(angularVelocity) < 0.03 {
            stopInertia()
            persistNow()
        }
    }

    // MARK: - Reset

    func reset() {
        guard let node = cameraNode else { return }
        stopInertia()
        stopReset()

        resetFromPosition = node.simdPosition
        resetFromOrientation = node.simdOrientation
        resetFromFOV = node.camera?.fieldOfView ?? initialFOV
        resetFromTarget = target
        resetStartTime = CACurrentMediaTime()

        let link = CADisplayLink(target: self, selector: #selector(stepReset(_:)))
        link.add(to: .main, forMode: .common)
        resetLink = link
    }

    private func stopReset() {
        resetLink?.invalidate()
        resetLink = nil
    }

    @objc private func stepReset(_ link: CADisplayLink) {
        guard let node = cameraNode else { stopReset(); return }

        let elapsed = CACurrentMediaTime() - resetStartTime
        let progress = min(elapsed / resetDuration, 1.0)
        let t = Float(progress < 0.5 ? 2 * progress * progress : 1 - pow(-2 * progress + 2, 2) / 2)

        node.simdPosition = resetFromPosition + (initialPosition - resetFromPosition) * t
        node.simdOrientation = simd_slerp(resetFromOrientation, initialOrientation, t)
        node.camera?.fieldOfView = resetFromFOV + (initialFOV - resetFromFOV) * CGFloat(t)
        target = resetFromTarget + (initialTarget - resetFromTarget) * t

        if progress >= 1.0 {
            node.simdTransform = initialTransform
            node.camera?.fieldOfView = initialFOV
            target = initialTarget
            stopReset()
            persistNow()
        }
    }

    // MARK: - Persistence

    @objc func persistNow() {
        guard let node = cameraNode else { return }
        CameraPersistence.save(node: node, target: target, for: model)
        lastSavedTransform = node.simdTransform
        lastSavedFOV = node.camera?.fieldOfView
    }

    private func startSaveTimer() {
        saveTimer?.invalidate()
        let timer = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.saveIfChanged()
        }
        RunLoop.main.add(timer, forMode: .common)
        saveTimer = timer
    }

    private func saveIfChanged() {
        guard let node = cameraNode else { return }
        if let last = lastSavedTransform,
           last == node.simdTransform,
           lastSavedFOV == node.camera?.fieldOfView {
            return
        }
        persistNow()
    }
}
