//
//  AlbumView.swift
//  TravelMemoir
//
//  相册视图
//  Created by 云眠 on 2026/02/27
//

import SwiftUI

struct AlbumView: View {
    @EnvironmentObject var dataController: TravelDataController
    @State private var selectedTravel: TravelEntry?

    var allPhotos: [(travel: TravelEntry, photo: String)] {
        dataController.travels.flatMap { travel in
            travel.photos.map { (travel, $0) }
        }
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 2),
                GridItem(.flexible(), spacing: 2),
                GridItem(.flexible(), spacing: 2)
            ], spacing: 2) {
                ForEach(allPhotos, id: \.photo) { item in
                    AsyncImage(url: URL(string: item.photo)) { image in
                        image
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .overlay(
                                ProgressView()
                            )
                    }
                    .clipped()
                    .onTapGesture {
                        selectedTravel = item.travel
                    }
                }
            }
        }
        .navigationTitle("相册")
        .sheet(item: $selectedTravel) { travel in
            TravelDetailView(travel: travel)
        }
    }
}

#Preview {
    NavigationView {
        AlbumView()
            .environmentObject(TravelDataController.preview)
    }
}
