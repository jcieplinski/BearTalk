//
//  StatsCell.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/30/23.
//

import SwiftUI

struct StatsCell: View {
    let title: String
    var stat: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.caption)
                .opacity(0.6)
            Spacer()
            Text(stat)
                .fontWeight(.semibold)
                .textSelection(.enabled)
        }
        .padding(.vertical, 8)
        .listRowBackground(Color.clear)
    }
}

#Preview {
    return List {
        StatsCell(title: "Nickname", stat: "Stella")
        StatsCell(title: "Nickname", stat: "Stella")
        StatsCell(title: "Nickname", stat: "Stella")
    }
}
