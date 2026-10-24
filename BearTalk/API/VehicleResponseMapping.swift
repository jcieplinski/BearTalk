//
//  VehicleResponseMapping.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/12/25.
//

import Foundation
import SwiftProtobuf
import BearTalkProto

extension BearAPI {
    static func mapUserProfileResponse(_ userProfile: Mobilegateway_Protos_UserProfile) -> UserProfile {
        return UserProfile(
            email: userProfile.email,
            locale: userProfile.locale,
            username: "",
            photoUrl: userProfile.photoURL,
            firstName: userProfile.firstName,
            lastName: userProfile.lastName,
            emaId: ""
        )
    }
    
    static func mapVehicleResponse(_ vehicle: Mobilegateway_Protos_Vehicle) -> Vehicle {
        let config = VehicleConfig(
            vin: vehicle.config.vin,
            model: LucidModel(proto: vehicle.config.model),
            modelVariant: ModelVariant(proto: vehicle.config.variant),
            releaseDate: nil,
            nickname: vehicle.config.nickname,
            paintColor: PaintColor(proto: vehicle.config.paintColor),
            emaId: "\(vehicle.config.emaID)",
            wheels: Wheels(proto: vehicle.config.wheels),
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
            edition: Edition(proto: vehicle.config.edition),
            battery: String(describing: vehicle.config.battery),
            interior: Interior(proto: vehicle.config.interior, colorCode: vehicle.config.interiorColorCode),
            specialIdentifiers: nil,
            look: Look(proto: vehicle.config.look),
            roof: RoofType(proto: vehicle.config.roof),
            exteriorColorCode: "\(vehicle.config.exteriorColorCode)",
            interiorColorCode: "\(vehicle.config.interiorColorCode)",
            frunkStrut: String(describing: vehicle.config.frunkStrut),
            frontSeatsHeating: FrontSeatsHeatingAvailability(proto: vehicle.config.frontSeatsHeating),
            frontSeatsVentilation: FrontSeatsVentilationAvailability(proto: vehicle.config.frontSeatsVentilation),
            secondRowHeatedSeats: SecondRowHeatedSeatsAvailability(proto: vehicle.config.secondRowHeatedSeats),
            heatedSteeringWheel: HeatedSteeringWheelAvailability(proto: vehicle.config.heatedSteeringWheel)
        )

        print("Interior debug \(vehicle.config.nickname): access=\(vehicle.accessLevel) proto=\(vehicle.config.interior) raw=\(vehicle.config.interior.rawValue) colorCode=\(vehicle.config.interiorColorCode.debugDescription) exteriorCode=\(vehicle.config.exteriorColorCode.debugDescription) mapped=\(config.interior.title) mappedRaw=\(config.interior.intValue) model=\(vehicle.config.model) variant=\(vehicle.config.variant) look=\(vehicle.config.look) wheels=\(vehicle.config.wheels) roof=\(vehicle.config.roof) rearSeat=\(vehicle.config.rearSeatConfig) edition=\(vehicle.config.edition) paint=\(vehicle.config.paintColor) doorPlate=\(vehicle.config.specialIdentifiers.doorPlate.debugDescription)")
        if let configBytes = try? vehicle.config.serializedData() {
            print("Interior debug \(vehicle.config.nickname) all config fields: \(decodeUnknownFields(configBytes))")
        }
        print("Cargo debug \(vehicle.config.nickname): frontCargo=\(vehicle.state.body.frontCargo) raw=\(vehicle.state.body.frontCargo.rawValue) rearCargo=\(vehicle.state.body.rearCargo) raw=\(vehicle.state.body.rearCargo.rawValue) FL=\(vehicle.state.body.frontLeftDoor.rawValue) FR=\(vehicle.state.body.frontRightDoor.rawValue) RL=\(vehicle.state.body.rearLeftDoor.rawValue) RR=\(vehicle.state.body.rearRightDoor.rawValue) chargePort=\(vehicle.state.body.chargePort.rawValue)")
        Self.logUnknownFields("config", vehicle.config.unknownFields.data)
        Self.logUnknownFields("specialIdentifiers", vehicle.config.specialIdentifiers.unknownFields.data)
        Self.logUnknownFields("body", vehicle.state.body.unknownFields.data)
        Self.logUnknownFields("state", vehicle.state.unknownFields.data)
        
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
    }

    private static func logUnknownFields(_ label: String, _ data: Data) {
        guard !data.isEmpty else { return }
        print("Unknown proto \(label): hex=\(data.map { String(format: "%02x", $0) }.joined()) decoded=\(decodeUnknownFields(data))")
    }

    private static func decodeUnknownFields(_ data: Data) -> String {
        var parts: [String] = []
        var offset = 0
        let bytes = [UInt8](data)

        func readVarint() -> UInt64? {
            var value: UInt64 = 0
            var shift = 0
            while offset < bytes.count {
                let byte = UInt64(bytes[offset])
                offset += 1
                value |= (byte & 0x7F) << shift
                if byte & 0x80 == 0 { return value }
                shift += 7
                if shift > 63 { return nil }
            }
            return nil
        }

        while offset < bytes.count {
            guard let tag = readVarint() else { break }
            let field = tag >> 3
            switch tag & 7 {
            case 0:
                if let value = readVarint() {
                    parts.append("f\(field)=\(value)")
                }
            case 1:
                offset = min(offset + 8, bytes.count)
                parts.append("f\(field)=fixed64")
            case 2:
                guard let length = readVarint() else { break }
                let end = min(offset + Int(length), bytes.count)
                let payload = bytes[offset..<end]
                offset = end
                if let text = String(bytes: payload, encoding: .utf8),
                   text.unicodeScalars.allSatisfy({ $0.isASCII && CharacterSet.controlCharacters.contains($0) == false }) {
                    parts.append("f\(field)=\"\(text)\"")
                } else {
                    parts.append("f\(field)=bytes:\(payload.map { String(format: "%02x", $0) }.joined())")
                }
            case 5:
                offset = min(offset + 4, bytes.count)
                parts.append("f\(field)=fixed32")
            default:
                parts.append("f\(field)=wire\(tag & 7)")
                offset = bytes.count
            }
        }

        return parts.joined(separator: " ")
    }
}
