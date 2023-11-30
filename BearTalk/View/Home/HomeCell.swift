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

    @Binding var image: String

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
        .padding(.vertical, 8)
        .listRowBackground(Color.clear)
    }
}

#Preview {
    return List {
        HomeCell(title: "Frunk", action: {}, image: .constant("car.side.rear.open"))
        HomeCell(title: "Frunk", action: {}, image: .constant("car.side.rear.open"))
        HomeCell(title: "Frunk", action: {}, image: .constant("car.side.rear.open"))
    }
}
