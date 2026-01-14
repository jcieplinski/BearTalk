//
//  EditableStatsCell.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 1/17/25.
//

import SwiftUI

struct EditableStatsCell: View {
    let title: String
    let stat: String
    let onEdit: () -> Void
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.caption)
                .opacity(0.6)
            
            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Text(stat)
                .font(.title3)
                .fontWeight(.semibold)
                .textSelection(.enabled)
        }
        .padding(.vertical, 8)
        .listRowBackground(Color.clear)
    }
}

#Preview {
    return List {
        EditableStatsCell(title: "Vehicle", stat: "Stella", onEdit: {})
    }
}
