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
    @AppStorage(DefaultsKey.carColor) static var carColor: String = "eurekaGold"
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
        try await withGRPCClient(
            transport: .http2NIOPosix(
                target: .dns(host: String.grpcAPI),
                transportSecurity: .tls
            )
        ) { client in
            let request = Mobilegateway_Protos_LogoutRequest()
            let metadata: GRPCCore.Metadata = ["authorization" : "Bearer \(authorization)"]
            
            do {
                let client = Mobilegateway_Protos_LoginSession.Client(wrapping: client)
                let _ = try await client.logout(
                    request,
                    metadata: metadata
                )
                
                authorization = ""
                refreshToken = ""
                return true
            } catch {
                print(error)
                return false
            }
        }
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
                let _ = try await client.wakeupVehicle(
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
                let _ = try await client.honkHorn(
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
        try await withGRPCClient(
            transport: .http2NIOPosix(
                target: .dns(host: String.grpcAPI),
                transportSecurity: .tls
            )
        ) { client in
            var request = Mobilegateway_Protos_DoorLocksControlRequest()
            request.vehicleID = vehicleID
            request.lockState = Mobilegateway_Protos_LockState(rawValue: lockState.intValue) ?? Mobilegateway_Protos_LockState.unknown
            request.doorLocation = [1, 2, 3, 4]
            
            let metadata: GRPCCore.Metadata = ["authorization" : "Bearer \(authorization)"]
            
            do {
                let client = Mobilegateway_Protos_VehicleStateService.Client(wrapping: client)
                let _ = try await client.doorLocksControl(
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
                    let _ = try await client.frontCargoControl(
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
                    let _ = try await client.rearCargoControl(
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
                let _ = try await client.controlChargePort(
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
    
    static func setChargeLimit(percentage: UInt32) async throws -> Bool {
        try await withGRPCClient(
            transport: .http2NIOPosix(
                target: .dns(host: String.grpcAPI),
                transportSecurity: .tls
            )
        ) { client in
            var request = Mobilegateway_Protos_SetChargeLimitRequest()
            request.vehicleID = vehicleID
            request.limitPercent = percentage
            
            let metadata: GRPCCore.Metadata = ["authorization" : "Bearer \(authorization)"]
            
            do {
                let client = Mobilegateway_Protos_VehicleStateService.Client(wrapping: client)
                let _ = try await client.setChargeLimit(
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
                let _ = try await client.lightsControl(
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
    
    static func setClimateControlState(state: HvacPower, temperature: Double) async throws -> Bool {
        try await withGRPCClient(
            transport: .http2NIOPosix(
                target: .dns(host: String.grpcAPI),
                transportSecurity: .tls
            )
        ) { client in
            var request = Mobilegateway_Protos_SetCabinTemperatureRequest()
            request.vehicleID = vehicleID
            request.state = Mobilegateway_Protos_HvacPower(rawValue: state.intValue) ?? .hvacOff
            
            if Locale.current.measurementSystem == .metric {
                request.temperature = temperature
            } else {
                let celsiusTemp = Measurement(value: temperature, unit: UnitTemperature.fahrenheit).converted(to: .celsius)
                request.temperature = celsiusTemp.value
            }
            
            let metadata: GRPCCore.Metadata = ["authorization" : "Bearer \(authorization)"]
            
            do {
                let client = Mobilegateway_Protos_VehicleStateService.Client(wrapping: client)
                let _ = try await client.setCabinTemperature(
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
    
    static func setTemperature(temperature: Double) async throws -> Bool {
        try await withGRPCClient(
            transport: .http2NIOPosix(
                target: .dns(host: String.grpcAPI),
                transportSecurity: .tls
            )
        ) { client in
            var request = Mobilegateway_Protos_SetCabinTemperatureRequest()
            request.vehicleID = vehicleID
            request.state = .hvacPrecondition
            
            if Locale.current.measurementSystem == .metric {
                request.temperature = temperature
            } else {
                let celsiusTemp = Measurement(value: temperature, unit: UnitTemperature.fahrenheit).converted(to: .celsius)
                request.temperature = celsiusTemp.value
            }
            
            let metadata: GRPCCore.Metadata = ["authorization" : "Bearer \(authorization)"]
            
            do {
                let client = Mobilegateway_Protos_VehicleStateService.Client(wrapping: client)
                let _ = try await client.setCabinTemperature(
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
    
    static func setMaxAC(state: MaxACState) async throws -> Bool {
        try await withGRPCClient(
            transport: .http2NIOPosix(
                target: .dns(host: String.grpcAPI),
                transportSecurity: .tls
            )
        ) { client in
            var request = Mobilegateway_Protos_SetMaxACRequest()
            request.vehicleID = vehicleID
            request.state = Mobilegateway_Protos_MaxACState(rawValue: state.intValue) ?? .unknown
            
            let metadata: GRPCCore.Metadata = ["authorization" : "Bearer \(authorization)"]
            
            do {
                let client = Mobilegateway_Protos_VehicleStateService.Client(wrapping: client)
                let _ = try await client.setMaxAC(
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

    static func defrostControl(action: DefrostState) async throws -> Bool {
        try await withGRPCClient(
            transport: .http2NIOPosix(
                target: .dns(host: String.grpcAPI),
                transportSecurity: .tls
            )
        ) { client in
            var request = Mobilegateway_Protos_HvacDefrostControlRequest()
            request.vehicleID = vehicleID
            request.hvacDefrost = Mobilegateway_Protos_DefrostState(rawValue: action.intvalue) ?? .unknown
            
            let metadata: GRPCCore.Metadata = ["authorization" : "Bearer \(authorization)"]
            
            do {
                let client = Mobilegateway_Protos_VehicleStateService.Client(wrapping: client)
                let _ = try await client.hvacDefrostControl(
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
    
    static func setSeatClimate(seats: [SeatAssignment]) async throws -> Bool {
        try await withGRPCClient(
            transport: .http2NIOPosix(
                target: .dns(host: String.grpcAPI),
                transportSecurity: .tls
            )
        ) { client in
            var request = Mobilegateway_Protos_SeatClimateControlRequest()
            request.vehicleID = vehicleID
            
            seats.forEach { seat in
                switch seat {
                case .driverHeatBackrestZone1(mode: let mode):
                    request.driverHeatBackrestZone1 = Mobilegateway_Protos_SeatClimateMode(rawValue: mode.intValue) ?? .unknown
                case .driverHeatBackrestZone3(mode: let mode):
                    request.driverHeatBackrestZone3 = Mobilegateway_Protos_SeatClimateMode(rawValue: mode.intValue) ?? .unknown
                case .driverHeatCushionZone2(mode: let mode):
                    request.driverHeatCushionZone2 = Mobilegateway_Protos_SeatClimateMode(rawValue: mode.intValue) ?? .unknown
                case .driverHeatCushionZone4(mode: let mode):
                    request.driverHeatCushionZone4 = Mobilegateway_Protos_SeatClimateMode(rawValue: mode.intValue) ?? .unknown
                case .driverVentBackrest(mode: let mode):
                    request.driverVentBackrest = Mobilegateway_Protos_SeatClimateMode(rawValue: mode.intValue) ?? .unknown
                case .driverVentCushion(mode: let mode):
                    request.driverVentCushion = Mobilegateway_Protos_SeatClimateMode(rawValue: mode.intValue) ?? .unknown
                case .frontPassengerHeatBackrestZone1(mode: let mode):
                    request.frontPassengerHeatBackrestZone1 = Mobilegateway_Protos_SeatClimateMode(rawValue: mode.intValue) ?? .unknown
                case .frontPassengerHeatBackrestZone3(mode: let mode):
                    request.frontPassengerHeatBackrestZone3 = Mobilegateway_Protos_SeatClimateMode(rawValue: mode.intValue) ?? .unknown
                case .frontPassengerHeatCushionZone2(mode: let mode):
                    request.frontPassengerHeatCushionZone2 = Mobilegateway_Protos_SeatClimateMode(rawValue: mode.intValue) ?? .unknown
                case .frontPassengerHeatCushionZone4(mode: let mode):
                    request.frontPassengerHeatCushionZone4 = Mobilegateway_Protos_SeatClimateMode(rawValue: mode.intValue) ?? .unknown
                case .frontPassengerVentBackrest(mode: let mode):
                    request.frontPassengerVentBackrest = Mobilegateway_Protos_SeatClimateMode(rawValue: mode.intValue) ?? .unknown
                case .frontPassengerVentCushion(mode: let mode):
                    request.frontPassengerVentCushion = Mobilegateway_Protos_SeatClimateMode(rawValue: mode.intValue) ?? .unknown
                case .rearPassengerHeatLeft(mode: let mode):
                    request.rearPassengerHeatLeft = Mobilegateway_Protos_SeatClimateMode(rawValue: mode.intValue) ?? .unknown
                case .rearPassengerHeatCenter(mode: let mode):
                    request.rearPassengerHeatCenter = Mobilegateway_Protos_SeatClimateMode(rawValue: mode.intValue) ?? .unknown
                case .rearPassengerHeatRight(mode: let mode):
                    request.rearPassengerHeatRight = Mobilegateway_Protos_SeatClimateMode(rawValue: mode.intValue) ?? .unknown
                }
            }
            
            let metadata: GRPCCore.Metadata = ["authorization" : "Bearer \(authorization)"]
            
            do {
                let client = Mobilegateway_Protos_VehicleStateService.Client(wrapping: client)
                let _ = try await client.seatClimateControl(
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
    
    static func setSteeringWheelHeat(status: SteeringHeaterStatus) async throws -> Bool {
        try await withGRPCClient(
            transport: .http2NIOPosix(
                target: .dns(host: String.grpcAPI),
                transportSecurity: .tls
            )
        ) { client in
            var request = Mobilegateway_Protos_SteeringWheelHeaterRequest()
            request.vehicleID = vehicleID
            
            switch status {
                
            case .unknown, .UNRECOGNIZED:
                break
            case .off:
                request.level = .off
            case .on:
                request.level = .steeringWheelHeaterLevel2
            }
            
            let metadata: GRPCCore.Metadata = ["authorization" : "Bearer \(authorization)"]
            
            do {
                let client = Mobilegateway_Protos_VehicleStateService.Client(wrapping: client)
                let _ = try await client.steeringWheelHeater(
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
    
    static func setBatteryPreCondition(status: PreconditioningStatus) async throws -> Bool {
        try await withGRPCClient(
            transport: .http2NIOPosix(
                target: .dns(host: String.grpcAPI),
                transportSecurity: .tls
            )
        ) { client in
            var request = Mobilegateway_Protos_SetBatteryPreconRequest()
            request.vehicleID = vehicleID
            request.status = Mobilegateway_Protos_BatteryPreconStatus(rawValue: status.intValue) ?? .batteryPreconUnknown
            
            let metadata: GRPCCore.Metadata = ["authorization" : "Bearer \(authorization)"]
            
            do {
                let client = Mobilegateway_Protos_VehicleStateService.Client(wrapping: client)
                let _ = try await client.setBatteryPrecon(
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
    
    static func setShockAndTilt(mode: AlarmMode) async throws -> Bool {
        try await withGRPCClient(
            transport: .http2NIOPosix(
                target: .dns(host: String.grpcAPI),
                transportSecurity: .tls
            )
        ) { client in
            var request = Mobilegateway_Protos_SecurityAlarmControlRequest()
            request.vehicleID = vehicleID
            request.mode = Mobilegateway_Protos_AlarmMode(rawValue: mode.intValue) ?? .unknown
            
            let metadata: GRPCCore.Metadata = ["authorization" : "Bearer \(authorization)"]
            
            do {
                let client = Mobilegateway_Protos_VehicleStateService.Client(wrapping: client)
                let _ = try await client.securityAlarmControl(
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
    
    static func startSoftwareUpdate() async throws -> Bool {
        try await withGRPCClient(
            transport: .http2NIOPosix(
                target: .dns(host: String.grpcAPI),
                transportSecurity: .tls
            )
        ) { client in
            var request = Mobilegateway_Protos_ApplySoftwareUpdateRequest()
            request.vehicleID = vehicleID
            
            let metadata: GRPCCore.Metadata = ["authorization" : "Bearer \(authorization)"]
            
            do {
                let client = Mobilegateway_Protos_VehicleStateService.Client(wrapping: client)
                let _ = try await client.applySoftwareUpdate(
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
