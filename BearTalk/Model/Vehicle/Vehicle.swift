//
//  Vehicle.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct Vehicle: Codable, Equatable {
    let vehicleId: String
    let accessLevel: String
    let vehicleConfig: VehicleConfig
    var vehicleState: VehicleState

    static func example() -> Vehicle? {
        if let filepath = Bundle.main.path(forResource: "sample", ofType: "json") {
            do {
                let contents = try String(contentsOfFile: filepath)
                let jsonData = contents.data(using: .utf8)!
                let decoder = JSONDecoder()
                return try! decoder.decode(Vehicle.self, from: jsonData)
            } catch {
                return nil
            }
        } else {
            return nil
        }

    }
}
