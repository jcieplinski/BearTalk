//
//  SoftwareUpdate.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct SoftwareUpdate: Codable, Equatable {
    let versionAvailable: String
    let installDurationMinutes: UInt32
    let percentComplete: UInt32
    let state: UpdateState
    let versionAvailableRaw: UInt32
    let updateAvailable: UpdateAvailability
    let scheduledStartTimeSec: UInt64
    let downloadStatus: SoftwareDownloadStatus
    let downloadInterface: SoftwareDownloadInterface
    let tcuDownloadStatus: TcuDownloadStatus
    
    init(proto: Mobilegateway_Protos_SoftwareUpdate) {
        versionAvailable = proto.versionAvailable
        installDurationMinutes = proto.installDurationMinutes
        percentComplete = proto.percentComplete
        state = .init(proto: proto.state)
        versionAvailableRaw = proto.versionAvailableRaw
        updateAvailable = .init(proto: proto.updateAvailable)
        scheduledStartTimeSec = proto.scheduledStartTimeSec
        downloadStatus = .init(proto: proto.downloadStatus)
        downloadInterface = .init(proto: proto.downloadInterface)
        tcuDownloadStatus = .init(proto: proto.tcuDownloadStatus)
    }
}

enum TcuDownloadStatus: Codable, Equatable {
    case tcuSoftwareDownloadStatusUnknown // = 0
    case tcuSoftwareDownloadStatusIdle // = 1
    case tcuSoftwareDownloadStatusDownloading // = 2
    case tcuSoftwareDownloadStatusDownloadPaused // = 3
    case tcuSoftwareDownloadStatusDownloadComplete // = 4
    case tcuSoftwareDownloadStatusDownloadFailed // = 5
    case tcuSoftwareDownloadStatusDownloadCanceled // = 6
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_TcuDownloadStatus) {
        switch proto {
        case .tcuSoftwareDownloadStatusUnknown: self = .tcuSoftwareDownloadStatusUnknown
        case .tcuSoftwareDownloadStatusIdle: self = .tcuSoftwareDownloadStatusIdle
        case .tcuSoftwareDownloadStatusDownloading: self = .tcuSoftwareDownloadStatusDownloading
        case .tcuSoftwareDownloadStatusDownloadPaused: self = .tcuSoftwareDownloadStatusDownloadPaused
        case .tcuSoftwareDownloadStatusDownloadComplete: self = .tcuSoftwareDownloadStatusDownloadComplete
        case .tcuSoftwareDownloadStatusDownloadFailed: self = .tcuSoftwareDownloadStatusDownloadFailed
        case .tcuSoftwareDownloadStatusDownloadCanceled: self = .tcuSoftwareDownloadStatusDownloadCanceled
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum SoftwareDownloadInterface: Codable, Equatable {
    case unknown // = 0
    case idle // = 1
    case wifiOnly // = 2
    case lte // = 3
    case any // = 4
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_SoftwareDownloadInterface) {
        switch proto {
        case .unknown: self = .unknown
        case .idle: self = .idle
        case .wifiOnly: self = .wifiOnly
        case .lte: self = .lte
        case .any: self = .any
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum SoftwareDownloadStatus: Codable, Equatable {
    case unknown // = 0
    case idle // = 1
    case downloading // = 2
    case downloadPaused // = 3
    case downloadComplete // = 4
    case downloadFailed // = 5
    case downloadCanceled // = 6
    case waitingOnWifi // = 7
    case waitingOnLte // = 8
    case pausedWaitingOnWifi // = 9
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_SoftwareDownloadStatus) {
        switch proto {
        case .unknown: self = .unknown
        case .idle: self = .idle
        case .downloading: self = .downloading
        case .downloadPaused: self = .downloadPaused
        case .downloadComplete: self = .downloadComplete
        case .downloadFailed: self = .downloadFailed
        case .downloadCanceled: self = .downloadCanceled
        case .waitingOnWifi: self = .waitingOnWifi
        case .waitingOnLte: self = .waitingOnLte
        case .pausedWaitingOnWifi: self = .pausedWaitingOnWifi
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum UpdateAvailability: Codable, Equatable {
    case unknown // = 0
    case updateAvailable // = 1
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_UpdateAvailability) {
        switch proto {
        case .unknown: self = .unknown
        case .updateAvailable: self = .updateAvailable
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum UpdateState: Codable, Equatable {
    case unknown // = 0
    case inProgress // = 1
    case success // = 2
    case failed // = 3
    case waitingOnBcm // = 4
    case updateFailedDriveAllowed // = 5
    case updateFailedNoAction // = 6
    case updateSuccessWithWarnings // = 7
    case updateNotstartedWithWarnings // = 8
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_UpdateState) {
        switch proto {
        case .unknown: self = .unknown
        case .inProgress: self = .inProgress
        case .success: self = .success
        case .failed: self = .failed
        case .waitingOnBcm: self = .waitingOnBcm
        case .updateFailedDriveAllowed: self = .updateFailedDriveAllowed
        case .updateFailedNoAction: self = .updateFailedNoAction
        case .updateSuccessWithWarnings: self = .updateSuccessWithWarnings
        case .updateNotstartedWithWarnings: self = .updateNotstartedWithWarnings
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}
