//
//  NoCarView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/30/23.
//

import SwiftUI

struct NoCarView: View {
    @Environment(AppState.self) var appState: AppState
    private let tokenManager = TokenManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                Spacer()
                Text("No Cars Found.")
                    .font(.title)
                Image("cosmos")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180)
                Text("Looks like your car has not arrived yet. Check back when your car is delivered to see updated stats.")
                Spacer()
            }
            .padding(44)
            .frame(maxWidth: .infinity)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        appState.logOut()
                    } label: {
                        Text("Log Out")
                    }
                }
            }
        }
    }
}

#Preview {
    NoCarView()
        .environment(AppState())
}
