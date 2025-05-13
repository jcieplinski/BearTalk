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
                        let config = VehicleConfig(
                            vin: vehicle.config.vin,
                            model: String(describing: vehicle.config.model),
                            modelVariant: String(describing: vehicle.config.variant),
                            releaseDate: nil,
                            nickname: vehicle.config.nickname,
                            paintColor: String(describing: vehicle.config.paintColor),
                            emaId: "\(vehicle.config.emaID)",
                            wheels: String(describing: vehicle.config.wheels),
                            easubscription: EASubscription(
                                name: vehicle.config.eaSubscription.name,
                                expirationDate: "\(vehicle.config.eaSubscription.expirationDate)",
                                startDate: "\(vehicle.config.eaSubscription.startDate)",
                                status: String(describing: vehicle.config.eaSubscription.status)
                            ),
                            chargingAccounts: vehicle.config.chargingAccounts.map { account in
                                ChargingAccount(
                                    emaid: "\(account.emaID)",
                                    vehicleId: "\(account.vehicleID)",
                                    status: String(describing: account.status),
                                    createdAtEpochSec: "\(account.createdAtEpochSec)",
                                    expiryOnEpocSec: "\(account.expiryOnEpochSec)",
                                    vendorName: String(describing: account.vendorName)
                                )
                            },
                            countryCode: vehicle.config.countryCode,
                            regionCode: vehicle.config.regionCode,
                            edition: String(describing: vehicle.config.edition),
                            battery: String(describing: vehicle.config.battery),
                            interior: String(describing: vehicle.config.interior),
                            specialIdentifiers: nil,
                            look: String(describing: vehicle.config.look),
                            exteriorColorCode: "\(vehicle.config.exteriorColorCode)",
                            interiorColorCode: "\(vehicle.config.interiorColorCode)",
                            frunkStrut: String(describing: vehicle.config.frunkStrut)
                        )
                        
                        let vehicleState = VehicleState(
                            batteryState: BatteryState(proto: vehicle.state.battery),
                            powerState: PowerState(proto: vehicle.state.power),
                            cabinState: CabinState(proto: vehicle.state.cabin),
                            bodyState: BodyState(proto: vehicle.state.body),
                            lastUpdatedMs: "\(vehicle.state.lastUpdatedMs)",
                            chassisState: ChassisState(proto: vehicle.state.chassis),
                            chargingState: ChargingState(proto: vehicle.state.charging),
                            gps: GPS(proto: vehicle.state.gps),
                            softwareUpdate: SoftwareUpdate(proto: vehicle.state.softwareUpdate),
                            alarmState: AlarmState(proto: vehicle.state.alarm),
                            cloudConnectionState: CloudConnection(proto: vehicle.state.cloudConnection),
                            keylessDrivingState: KeylessDrivingState(proto: vehicle.state.keylessDriving),
                            hvacState: HVACState(proto: vehicle.state.hvac),
                            driveMode: DriveMode(proto: vehicle.state.driveMode),
                            privacyMode: PrivacyMode(proto: vehicle.state.privacyMode),
                            gearPosition: GearPosition(proto: vehicle.state.gearPosition),
                            mobileAppReqStatus: MobileAppReqStatus(proto: vehicle.state.mobileAppRequest),
                            tcuState: TcuState(proto: vehicle.state.tcu),
                            tcuInternetStatus: TCUInternetStatus(proto: vehicle.state.tcuInternet)
                        )
                        
                        return Vehicle(
                            vehicleId: vehicle.vehicleID,
                            accessLevel: AccessLevel(proto: vehicle.accessLevel),
                            vehicleConfig: config,
                            vehicleState: vehicleState
                        )
                    },
                    encryption: response.encryption == .single ? "single" : "unknown"
                )
                
                // Update vehicle ID and car color if available
                if let firstVehicle = loginResponse.userVehicleData.first {
                    vehicleID = firstVehicle.vehicleId
                    let paintColor = firstVehicle.vehicleConfig.paintColor
                    if let color = CarColor(rawValue: paintColor)?.image {
                        carColor = color
                    }
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
//        let request = URLRequest(url: URL(string: .baseAPI + .userVehicles)!)
//        var authRequest = addAuthHeader(to: request)
//
//        authRequest.addValue("application/JSON", forHTTPHeaderField: "Content-Type")
//
//        do {
//            let (data, _) = try await URLSession.shared.data(for: authRequest)
//            let vehicles = try JSONDecoder().decode(UserVehiclesReponse.self, from: data).userVehicleData
//
//            return vehicles
//        } catch let error {
//            print(error)
//            return nil
//        }
        
        return nil
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
