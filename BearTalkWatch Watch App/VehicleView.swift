//
//  VehicleView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 6/13/25.
//

import SwiftUI
import SwiftData

struct VehicleView: View {
    @Environment(\.modelContext) var modelContext
    @AppStorage(DefaultsKey.vehicleID, store: .appGroup) static var vehicleID: String = ""
    
    @Bindable var model: VehicleViewModel
    
    var body: some View {
        HStack {
            VStack {
                if model.nickname.isNotBlank {
                    Text(model.nickname)
                        .font(.headline)
                }
                
                Text("\(model.chargePercent.rounded().stringWithLocale())%")
                    .font(.title)
            }
            
            if let snapshotData = model.snapshotData,
               let uiImage = UIImage(data: snapshotData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 400, maxHeight: 80)
            }
        }
        .task {
            await model.setup()
        }
    }
}
