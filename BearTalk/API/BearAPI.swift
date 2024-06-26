//
//  BearAPI.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import SwiftUI

final class BearAPI {
    @AppStorage(DefaultsKey.authorization) static var authorization: String = ""
    @AppStorage(DefaultsKey.refreshToken) static var refreshToken: String = ""
    @AppStorage(DefaultsKey.vehicleID) static var vehicleID: String = ""
    @AppStorage(DefaultsKey.carColor) static var carColor: String = "eureka"
    @AppStorage(DefaultsKey.lastEfficiency) var lastEfficiency: Double = 3.2

    private static func addAuthHeader(to urlRequest: URLRequest) -> URLRequest {
        var request = urlRequest
        if authorization.isNotBlank {
            request.addValue("Bearer \(authorization)", forHTTPHeaderField: "authorization")
        }
        return request
    }

    static func logIn(userName: String, password: String) async throws -> (loginResponse: LoginResponse?, response: URLResponse?) {
        var request = URLRequest(url: URL(string: .baseAPI + .login)!)

        request.httpMethod = "POST"
        request.addValue("application/JSON", forHTTPHeaderField: "Content-Type")

        let parameters: [String : Any] = [
                    "username": userName,
                    "password": password,
                    "os": 1,
                    "notification_channel_type": 1,
                    "notification_device_token": "1234",
                    "locale": "en_US",
                    "device_id": "python-lucidmotors"
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch let error {
            print(error.localizedDescription)
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        authorization = loginResponse.sessionInfo.idToken
        refreshToken = loginResponse.sessionInfo.refreshToken
        vehicleID = loginResponse.userVehicleData.first?.vehicleId ?? ""
        
        if let paintColor = loginResponse.userVehicleData.first?.vehicleConfig.paintColor, let color = CarColor(rawValue: paintColor)?.image {
            carColor = color
        }

        return (loginResponse: loginResponse, response: response)
    }

    static func logOut() async throws -> Bool {
        authorization = ""
        refreshToken = ""

        return true
    }

    static func refreshToken() async throws -> Int {
        var request = URLRequest(url: URL(string: .baseAPI + .refreshToken)!)

        request.httpMethod = "POST"
        request.addValue("application/JSON", forHTTPHeaderField: "Content-Type")

        let parameters: [String : Any] = ["refresh_token": refreshToken]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            let (data, _) = try await URLSession.shared.data(for: request)
            let sessionInfo = try JSONDecoder().decode(RefreshResponse.self, from: data).sessionInfo
            authorization = sessionInfo.idToken
            refreshToken = sessionInfo.refreshToken

            return sessionInfo.expiryTimeSec
        } catch let error {
            print(error)
            authorization = ""
            refreshToken = ""
            return 0
        }
    }

    static func fetchVehicles() async throws -> [Vehicle]? {
        let request = URLRequest(url: URL(string: .baseAPI + .userVehicles)!)
        var authRequest = addAuthHeader(to: request)

        authRequest.addValue("application/JSON", forHTTPHeaderField: "Content-Type")

        do {
            let (data, _) = try await URLSession.shared.data(for: authRequest)
            let vehicles = try JSONDecoder().decode(UserVehiclesReponse.self, from: data).userVehicleData

            return vehicles
        } catch let error {
            print(error)
            return nil
        }
    }

    static func fetchCurrentVehicle() async throws -> Vehicle? {
        do {
            let vehicles = try await fetchVehicles() ?? []

            let vehicle = vehicleID.isNotBlank ? vehicles.first(where: { $0.vehicleId == vehicleID }) : vehicles.first

            if let paintColor = vehicle?.vehicleConfig.paintColor, let color = CarColor(rawValue: paintColor)?.image {
                carColor = color
            }

            return vehicle
        } catch let error {
            print("Could not fetch current vehicle \(error)")
            return nil
        }
    }

    static func wakeUp() async throws -> Bool {
        let request = URLRequest(url: URL(string: .baseAPI + .wakeUp)!)
        var authRequest = addAuthHeader(to: request)

        authRequest.httpMethod = "POST"
        authRequest.addValue("application/JSON", forHTTPHeaderField: "Content-Type")

        let parameters: [String : Any] = ["vehicle_id": vehicleID]

        do {
            authRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            let _ = try await URLSession.shared.data(for: authRequest)

            return true
        } catch let error {
            print(error)
            return false
        }
    }

    static func honkHorn() async throws -> Bool {
        let request = URLRequest(url: URL(string: .baseAPI + .honkHorn)!)
        var authRequest = addAuthHeader(to: request)

        authRequest.httpMethod = "POST"
        authRequest.addValue("application/JSON", forHTTPHeaderField: "Content-Type")

        let parameters: [String : Any] = ["vehicle_id": vehicleID]

        do {
            authRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            let _ = try await URLSession.shared.data(for: authRequest)

            return true
        } catch let error {
            print(error)
            return false
        }
    }

    static func doorLockControl(lockState: LockState) async throws -> Bool {
        let request = URLRequest(url: URL(string: .baseAPI + .doorLocksControl)!)
        var authRequest = addAuthHeader(to: request)

        authRequest.httpMethod = "POST"
        authRequest.addValue("application/JSON", forHTTPHeaderField: "Content-Type")

        let parameters: [String : Any] = ["vehicle_id": vehicleID, "lock_state": lockState.rawValue, "door_location": [1,2,3,4]]

        do {
            authRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            let _ = try await URLSession.shared.data(for: authRequest)

            return true
        } catch let error {
            print(error)
            return false
        }
    }

    static func cargoControl(area: Cargo, closureState: ClosureState) async throws -> Bool {
        let request = URLRequest(url: URL(string: .baseAPI + area.controlURL)!)
        var authRequest = addAuthHeader(to: request)

        authRequest.httpMethod = "POST"
        authRequest.addValue("application/JSON", forHTTPHeaderField: "Content-Type")

        let parameters: [String : Any] = ["vehicle_id": vehicleID, "closure_state": closureState.rawValue]

        do {
            authRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            let _ = try await URLSession.shared.data(for: authRequest)

            return true
        } catch let error {
            print(error)
            return false
        }
    }

    static func chargePortControl(closureState: ClosureState) async throws -> Bool {
        let request = URLRequest(url: URL(string: .baseAPI + .chargePortControl)!)
        var authRequest = addAuthHeader(to: request)

        authRequest.httpMethod = "POST"
        authRequest.addValue("application/JSON", forHTTPHeaderField: "Content-Type")

        let parameters: [String : Any] = ["vehicle_id": vehicleID, "closure_state": closureState.rawValue]

        do {
            authRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            let _ = try await URLSession.shared.data(for: authRequest)

            return true
        } catch let error {
            print(error)
            return false
        }
    }

    static func lightsControl(action: LightsAction) async throws -> Bool {
        let request = URLRequest(url: URL(string: .baseAPI + .lightsControl)!)
        var authRequest = addAuthHeader(to: request)

        authRequest.httpMethod = "POST"
        authRequest.addValue("application/JSON", forHTTPHeaderField: "Content-Type")

        let parameters: [String : Any] = ["vehicle_id": vehicleID, "action": action.rawValue]

        do {
            authRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            let _ = try await URLSession.shared.data(for: authRequest)

            return true
        } catch let error {
            print(error)
            return false
        }
    }

    static func defrostControl(action: DefrostAction) async throws -> Bool {
        let request = URLRequest(url: URL(string: .baseAPI + .defrostControl)!)
        var authRequest = addAuthHeader(to: request)

        authRequest.httpMethod = "POST"
        authRequest.addValue("application/JSON", forHTTPHeaderField: "Content-Type")

        let parameters: [String : Any] = ["vehicle_id": vehicleID, "hvac_defrost": action.rawValue]

        do {
            authRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            let _ = try await URLSession.shared.data(for: authRequest)

            return true
        } catch let error {
            print(error)
            return false
        }
    }
}
