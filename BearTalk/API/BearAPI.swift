//
//  BearAPI.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import SwiftUI
import GRPCCore
import GRPCNIOTransportHTTP2
import GRPCProtobuf

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

    @MainActor
    static func logIn(userName: String, password: String) async throws -> (loginResponse: LoginResponse?, response: URLResponse?) {
        try await withGRPCClient(
            transport: .http2NIOPosix(
                target: .dns(host: String.grpcAPI),
                transportSecurity: .tls
            )
        ) { client in
            var request = Mobilegateway_Protos_LoginRequest()
            request.username = userName
            request.password = password
            request.notificationChannelType = .notificationChannelOne
            request.os = .ios
            request.notificationDeviceToken = "1234"
            request.locale = "en_US"
            request.deviceID = "python-lucidmotors"
            request.clientName = "BearTalk"
            
            do {
                let loginClient = Mobilegateway_Protos_LoginSession.Client(wrapping: client)
                let response = try await loginClient.login(request)
                
                // Update stored credentials
                authorization = response.sessionInfo.idToken
                refreshToken = response.sessionInfo.refreshToken
                
                // Convert gRPC response to our model
                let loginResponse = LoginResponse(
                    uid: response.uid,
                    sessionInfo: SessionInfo(
                        idToken: response.sessionInfo.idToken,
                        expiryTimeSec: Int(response.sessionInfo.expiryTimeSec),
                        refreshToken: response.sessionInfo.refreshToken,
                        gigyaJwt: response.sessionInfo.gigyaJwt
                    ),
                    userProfile: UserProfile(
                        email: response.userProfile.email,
                        locale: response.userProfile.locale,
                        username: response.userProfile.username,
                        photoUrl: response.userProfile.photoURL,
                        firstName: response.userProfile.firstName,
                        lastName: response.userProfile.lastName,
                        emaId: response.uid
                    ),
                    userVehicleData: response.userVehicleData.map { vehicle in
                        return mapVehicleResponse(vehicle)
                    },
                    encryption: response.encryption == .single ? "single" : "unknown"
                )
                
                // Update vehicle ID and car color if available
                if let firstVehicle = loginResponse.userVehicleData.first {
                    vehicleID = firstVehicle.vehicleId
                    let paintColor = firstVehicle.vehicleConfig.paintColor
                    carColor = paintColor.image
                }
                
                return (loginResponse: loginResponse, response: nil)
            } catch {
                print("gRPC login error: \(error)")
                throw error
            }
        }
    }

    static func logOut() async throws -> Bool {
        authorization = ""
        refreshToken = ""

        return true
    }

    @MainActor
    static func refreshToken() async throws -> Int {
        try await withGRPCClient(
            transport: .http2NIOPosix(
                target: .dns(host: String.grpcAPI),
                transportSecurity: .tls
            )
        ) { client in
            var request = Mobilegateway_Protos_GetNewJWTTokenRequest()
            request.refreshToken = refreshToken
            
            do {
                let loginClient = Mobilegateway_Protos_LoginSession.Client(wrapping: client)
                let response = try await loginClient.getNewJWTToken(request)
                
                // Update stored credentials
                authorization = response.sessionInfo.idToken
                refreshToken = response.sessionInfo.refreshToken
                
                return Int(response.sessionInfo.expiryTimeSec)
            } catch {
                print("gRPC refresh token error: \(error)")
                authorization = ""
                refreshToken = ""
                throw error
            }
        }
    }

    @MainActor
    static func fetchVehicles() async throws -> [Vehicle]? {
        try await withGRPCClient(
            transport: .http2NIOPosix(
                target: .dns(host: String.grpcAPI),
                transportSecurity: .tls
            )
        ) { client in
            let request = Mobilegateway_Protos_GetUserVehiclesRequest()
            let metadata: GRPCCore.Metadata = ["authorization" : "Bearer \(authorization)"]
            
            do {
                let fetchClient = Mobilegateway_Protos_LoginSession.Client(wrapping: client)
                let response = try await fetchClient.getUserVehicles(
                    request,
                    metadata: metadata
                )
                
                return response.userVehicleData.map { vehicle in
                    return mapVehicleResponse(vehicle)
                }
            } catch {
                print(error)
                return nil
            }
        }
    }

    @MainActor
    static func fetchCurrentVehicle() async throws -> Vehicle? {
        do {
            let vehicles = try await fetchVehicles() ?? []

            let vehicle = vehicleID.isNotBlank ? vehicles.first(where: { $0.vehicleId == vehicleID }) : vehicles.first

            if let paintColor = vehicle?.vehicleConfig.paintColor {
                carColor = paintColor.image
            }

            return vehicle
        } catch let error {
            print("Could not fetch current vehicle \(error)")
            return nil
        }
    }

    static func wakeUp() async throws -> Bool {
        try await withGRPCClient(
            transport: .http2NIOPosix(
                target: .dns(host: String.grpcAPI),
                transportSecurity: .tls
            )
        ) { client in
            var request = Mobilegateway_Protos_WakeupVehicleRequest()
            request.vehicleID = vehicleID
            let metadata: GRPCCore.Metadata = ["authorization" : "Bearer \(authorization)"]
            
            do {
                let client = Mobilegateway_Protos_VehicleStateService.Client(wrapping: client)
                let response = try await client.wakeupVehicle(
                    request,
                    metadata: metadata
                )
                
                return true
            } catch {
                print(error)
                return false
            }
        }
    }

    static func honkHorn() async throws -> Bool {
        try await withGRPCClient(
            transport: .http2NIOPosix(
                target: .dns(host: String.grpcAPI),
                transportSecurity: .tls
            )
        ) { client in
            var request = Mobilegateway_Protos_HonkHornRequest()
            request.vehicleID = vehicleID
            let metadata: GRPCCore.Metadata = ["authorization" : "Bearer \(authorization)"]
            
            do {
                let client = Mobilegateway_Protos_VehicleStateService.Client(wrapping: client)
                let response = try await client.honkHorn(
                    request,
                    metadata: metadata
                )
                
                return true
            } catch {
                print(error)
                return false
            }
        }
    }

    static func doorLockControl(lockState: LockState) async throws -> Bool {
//        let request = URLRequest(url: URL(string: .baseAPI + .doorLocksControl)!)
//        var authRequest = addAuthHeader(to: request)
//
//        authRequest.httpMethod = "POST"
//        authRequest.addValue("application/JSON", forHTTPHeaderField: "Content-Type")
//
//        let parameters: [String : Any] = ["vehicle_id": vehicleID, "lock_state": lockState.rawValue, "door_location": [1,2,3,4]]
//
//        do {
//            authRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters)
//            let _ = try await URLSession.shared.data(for: authRequest)
//
//            return true
//        } catch let error {
//            print(error)
//            return false
//        }
        
        return false
    }

    static func cargoControl(area: Cargo, closureState: DoorState) async throws -> Bool {
        try await withGRPCClient(
            transport: .http2NIOPosix(
                target: .dns(host: String.grpcAPI),
                transportSecurity: .tls
            )
        ) { client in
            switch area {
            case .frunk:
                var request = Mobilegateway_Protos_FrontCargoControlRequest()
                request.vehicleID = vehicleID
                request.closureState = Mobilegateway_Protos_DoorState(rawValue: closureState.intValue) ?? Mobilegateway_Protos_DoorState.unknown
                
                let metadata: GRPCCore.Metadata = ["authorization" : "Bearer \(authorization)"]
                
                do {
                    let client = Mobilegateway_Protos_VehicleStateService.Client(wrapping: client)
                    let response = try await client.frontCargoControl(
                        request,
                        metadata: metadata
                    )
                    
                    return true
                } catch {
                    print(error)
                    return false
                }
            case .trunk:
                var request = Mobilegateway_Protos_RearCargoControlRequest()
                request.vehicleID = vehicleID
                request.closureState = Mobilegateway_Protos_DoorState(rawValue: closureState.intValue) ?? Mobilegateway_Protos_DoorState.unknown
                
                let metadata: GRPCCore.Metadata = ["authorization" : "Bearer \(authorization)"]
                
                do {
                    let client = Mobilegateway_Protos_VehicleStateService.Client(wrapping: client)
                    let response = try await client.rearCargoControl(
                        request,
                        metadata: metadata
                    )
                    
                    return true
                } catch {
                    print(error)
                    return false
                }
            }
        }
    }

    static func chargePortControl(closureState: DoorState) async throws -> Bool {
        try await withGRPCClient(
            transport: .http2NIOPosix(
                target: .dns(host: String.grpcAPI),
                transportSecurity: .tls
            )
        ) { client in
            var request = Mobilegateway_Protos_ControlChargePortRequest()
            request.vehicleID = vehicleID
            request.closureState = Mobilegateway_Protos_DoorState(rawValue: closureState.intValue) ?? Mobilegateway_Protos_DoorState.unknown
            
            let metadata: GRPCCore.Metadata = ["authorization" : "Bearer \(authorization)"]
            
            do {
                let client = Mobilegateway_Protos_VehicleStateService.Client(wrapping: client)
                let response = try await client.controlChargePort(
                    request,
                    metadata: metadata
                )
                
                return true
            } catch {
                print(error)
                return false
            }
        }
    }

    static func lightsControl(action: LightAction) async throws -> Bool {
        try await withGRPCClient(
            transport: .http2NIOPosix(
                target: .dns(host: String.grpcAPI),
                transportSecurity: .tls
            )
        ) { client in
            var request = Mobilegateway_Protos_LightsControlRequest()
            request.vehicleID = vehicleID
            request.action = Mobilegateway_Protos_LightAction(rawValue: action.intValue) ?? Mobilegateway_Protos_LightAction.unknown
            
            let metadata: GRPCCore.Metadata = ["authorization" : "Bearer \(authorization)"]
            
            do {
                let client = Mobilegateway_Protos_VehicleStateService.Client(wrapping: client)
                let response = try await client.lightsControl(
                    request,
                    metadata: metadata
                )
                
                return true
            } catch {
                print(error)
                return false
            }
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
