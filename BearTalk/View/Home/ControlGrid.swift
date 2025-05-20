//
//  ControlGrid.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/17/25.
//

import SwiftUI

struct ControlGrid: View {
    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            alignment: .center,
            spacing: 16
        ) {
            
        }
    }
}

#Preview {
    ControlGrid()
}
