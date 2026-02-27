//
//  MapView.swift
//  TravelMemoir
//
//  地图视图
//  Created by 云眠 on 2026/02/27
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var dataController: TravelDataController
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503), // Tokyo
        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    )

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: dataController.travels) { travel in
            MapAnnotation(coordinate: travel.location?.coordinate ?? CLLocationCoordinate2D()) {
                TravelMapAnnotation(travel: travel)
            }
        }
        .navigationTitle("旅行地图")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: resetToAllPins) {
                    Image(systemName: "location.fill")
                }
            }
        }
    }

    private func resetToAllPins() {
        // 显示所有旅行的位置
        if let firstTravel = dataController.travels.first,
           let location = firstTravel.location {
            region.center = location.coordinate
        }
    }
}

struct TravelMapAnnotation: View {
    let travel: TravelEntry

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "mappin.circle.fill")
                .font(.title)
                .foregroundColor(.red)

            Text(travel.destination)
                .font(.caption)
                .padding(4)
                .background(Color.white)
                .cornerRadius(4)
        }
    }
}

#Preview {
    NavigationView {
        MapView()
            .environmentObject(TravelDataController.preview)
    }
}
