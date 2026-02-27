//
//  TravelEntry.swift
//  TravelMemoir
//
//  旅行记录模型
//  Created by 云眠 on 2026/02/27
//

import Foundation
import CoreLocation

struct TravelEntry: Identifiable, Codable {
    let id: UUID
    var title: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var coverImage: String?
    var photos: [String]
    var notes: String
    var rating: Int // 1-5
    var tags: [String]
    var location: LocationCoordinate?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        destination: String,
        startDate: Date,
        endDate: Date,
        coverImage: String? = nil,
        photos: [String] = [],
        notes: String = "",
        rating: Int = 5,
        tags: [String] = [],
        location: LocationCoordinate? = nil
    ) {
        self.id = id
        self.title = title
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.coverImage = coverImage
        self.photos = photos
        self.notes = notes
        self.rating = rating
        self.tags = tags
        self.location = location
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var duration: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
}

struct LocationCoordinate: Codable {
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

enum TravelTag: String, CaseIterable, Codable {
    case nature = "自然风光"
    case city = "城市探索"
    case beach = "海滨度假"
    case mountain = "山地徒步"
    case culture = "文化体验"
    case food = "美食之旅"
    case adventure = "冒险探险"
    case relax = "休闲放松"
    case romance = "浪漫之旅"
    case family = "家庭旅行"

    var icon: String {
        switch self {
        case .nature: return "tree.fill"
        case .city: return "building.2.fill"
        case .beach: return "sun.max.fill"
        case .mountain: return "mountain.2.fill"
        case .culture: return "building.columns.fill"
        case .food: return "fork.knife"
        case .adventure: return "figure.climbing"
        case .relax: return "bed.double.fill"
        case .romance: return "heart.fill"
        case .family: return "figure.2.and.child.holdinghands"
        }
    }
}
