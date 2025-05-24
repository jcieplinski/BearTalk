//
//  VehicleResponseMapping.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/12/25.
//

import Foundation
import SwiftProtobuf

extension BearAPI {
    static func mapUserProfileResponse(_ userProfile: Mobilegateway_Protos_UserProfileData) -> UserProfile {
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
            interior: Interior(proto: vehicle.config.interior),
            specialIdentifiers: nil,
            look: Look(proto: vehicle.config.look),
            roof: RoofType(proto: vehicle.config.roof),
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
    }
}
