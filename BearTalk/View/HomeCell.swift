//
//  HomeCell.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import SwiftUI

struct HomeCell: View {
    let title: String
    let action: () -> Void

    @State var image: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
            Spacer()
            Button {
                action()
            } label: {
                Image(systemName: image)
                    .font(.title)
                    .foregroundStyle(Color.accentColor)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical)
    }
}

#Preview {
    HomeCell(title: "Frunk", action: {}, image: "car.side.rear.open")
}