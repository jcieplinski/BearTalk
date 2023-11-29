//
//  SoftwareUpdate.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct SoftwareUpdate: Codable {
    let versionAvailable: String
    let installDurationMinutes: Int
    let percentComplete: Int
    let updateState: String
    let rollbackState: String
    let rollbackPercentComplete: Int
    let versionAvailableRaw: Int
    let updateAvailable: String
    let scheduledStartTimeSec: String
}
