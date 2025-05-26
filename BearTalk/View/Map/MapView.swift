//
//  MapView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 12/7/23.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(AppState.self) var appState: AppState
    @Environment(DataModel.self) var model
    
    @State var position: MapCameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    StatsCell(title: "Latitude", stat: model.latitude)
                    StatsCell(title: "Longitude", stat: model.longitude)
                    StatsCell(title: "Elevation", stat: model.elevation)
                }
                .padding()
                Map(position: $position) {
                    Annotation(coordinate: model.coordinate) {
                        CarSnapshotView()
                            .frame(width: 80, height: 80)
                            .rotationEffect(
                                Angle(degrees: model.heading)
                            )
                    } label: {
                        Text("")
                    }
                    
                }
                .task {
                    position = .region(MKCoordinateRegion(center: model.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
                }
            }
            .navigationTitle("Location")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                LinearGradient(gradient: Gradient(colors: appState.backgroundColors), startPoint: .top, endPoint: .bottom)
            )
        }
    }
}

#Preview {
    MapView()
        .environment(AppState())
        .environment(DataModel())
}

