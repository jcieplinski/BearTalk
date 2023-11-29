//
//  AppState.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import SwiftUI

final class AppState: ObservableObject {
    @Published var loggedIn: Bool = false
    @Published var appHoldScreen: Bool = true
}
