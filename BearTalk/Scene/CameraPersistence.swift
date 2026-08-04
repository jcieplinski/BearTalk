//
//  CameraPersistence.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 8/2/26.
//

import SceneKit
import Foundation
import OSLog
import simd

/// Persists and restores the user-adjusted camera position (rotation/zoom/pan)
/// for each car scene so the home tab reopens at the last-viewed angle.
enum CameraPersistence {
    private static var store: UserDefaults { .appGroup }

    private static func transformKey(for model: CarSceneModel) -> String {
        "\(DefaultsKey.cameraState)_transform_\(model.rawValue)"
    }

    private static func fovKey(for model: CarSceneModel) -> String {
        "\(DefaultsKey.cameraState)_fov_\(model.rawValue)"
    }

    private static func targetKey(for model: CarSceneModel) -> String {
        "\(DefaultsKey.cameraState)_target_\(model.rawValue)"
    }

    /// Saves the camera node's current transform, field of view, and orbit target.
    ///
    /// `OrbitCameraController` owns the point-of-view node directly, so its model
    /// `transform` is authoritative for where the user actually is.
    static func save(node: SCNNode, target: simd_float3, for model: CarSceneModel) {
        let t = node.transform
        let values: [Double] = [
            Double(t.m11), Double(t.m12), Double(t.m13), Double(t.m14),
            Double(t.m21), Double(t.m22), Double(t.m23), Double(t.m24),
            Double(t.m31), Double(t.m32), Double(t.m33), Double(t.m34),
            Double(t.m41), Double(t.m42), Double(t.m43), Double(t.m44)
        ]
        store.set(values, forKey: transformKey(for: model))

        if let fov = node.camera?.fieldOfView {
            store.set(Double(fov), forKey: fovKey(for: model))
        }

        store.set([Double(target.x), Double(target.y), Double(target.z)],
                  forKey: targetKey(for: model))

        Logger.vehicle.info("SAVE \(model.rawValue) pos=(\(t.m41), \(t.m42), \(t.m43)) fov=\(node.camera?.fieldOfView ?? -1)")
    }

    /// Restores a previously saved transform/FOV onto the camera node.
    /// - Returns: `true` if a saved state was applied.
    @discardableResult
    static func restore(node: SCNNode, for model: CarSceneModel) -> Bool {
        guard let raw = store.array(forKey: transformKey(for: model)) else {
            return false
        }

        let values = raw.compactMap { ($0 as? NSNumber)?.doubleValue }
        guard values.count == 16 else {
            return false
        }

        let transform = SCNMatrix4(
            m11: SCNFloat(values[0]), m12: SCNFloat(values[1]), m13: SCNFloat(values[2]), m14: SCNFloat(values[3]),
            m21: SCNFloat(values[4]), m22: SCNFloat(values[5]), m23: SCNFloat(values[6]), m24: SCNFloat(values[7]),
            m31: SCNFloat(values[8]), m32: SCNFloat(values[9]), m33: SCNFloat(values[10]), m34: SCNFloat(values[11]),
            m41: SCNFloat(values[12]), m42: SCNFloat(values[13]), m43: SCNFloat(values[14]), m44: SCNFloat(values[15])
        )
        node.transform = transform

        if node.camera != nil, store.object(forKey: fovKey(for: model)) != nil {
            node.camera?.fieldOfView = CGFloat(store.double(forKey: fovKey(for: model)))
        }

        Logger.vehicle.info("RESTORE \(model.rawValue) pos=(\(transform.m41), \(transform.m42), \(transform.m43)) fov=\(node.camera?.fieldOfView ?? -1)")

        return true
    }

    /// Restores the previously saved orbit target, if any.
    static func restoreTarget(for model: CarSceneModel) -> simd_float3? {
        guard let raw = store.array(forKey: targetKey(for: model)) else {
            return nil
        }
        let values = raw.compactMap { ($0 as? NSNumber)?.doubleValue }
        guard values.count == 3 else {
            return nil
        }
        return simd_float3(Float(values[0]), Float(values[1]), Float(values[2]))
    }

    static func clear(for model: CarSceneModel) {
        store.removeObject(forKey: transformKey(for: model))
        store.removeObject(forKey: fovKey(for: model))
        store.removeObject(forKey: targetKey(for: model))
    }
}
