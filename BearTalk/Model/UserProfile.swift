//
//  UserProfile.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct UserProfile: Codable, Equatable {
    let email: String
    let locale: String
    let username: String
    var photoUrl: String
    let firstName: String
    let lastName: String
    let emaId: String
}
