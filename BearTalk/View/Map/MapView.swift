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
    @EnvironmentObject private var appState: AppState

    @Bindable var model: MapViewModel

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
                        Image(appState.carColor)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(8)
                            .frame(width: 50)
                            .rotationEffect(
                                Angle(degrees: model.heading)
                            )
                    } label: {
                        Text("")
                    }

                }
                .task {
                    await model.fetchVehicle()
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
    MapView(model: MapViewModel())
        .environmentObject(AppState())
}

