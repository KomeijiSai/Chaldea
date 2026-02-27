//
//  TravelDataController.swift
//  TravelMemoir
//
//  数据控制器
//  Created by 云眠 on 2026/02/27
//

import Foundation
import CoreData

class TravelDataController: ObservableObject {
    static let shared = TravelDataController()

    @Published var travels: [TravelEntry] = []

    init() {
        loadSampleData()
    }

    // MARK: - Sample Data

    private func loadSampleData() {
        travels = [
            TravelEntry(
                title: "东京之旅",
                destination: "日本东京",
                startDate: Date().addingTimeInterval(-86400 * 30),
                endDate: Date().addingTimeInterval(-86400 * 25),
                notes: "樱花季的东京，美不胜收！",
                rating: 5,
                tags: ["城市探索", "美食之旅", "文化体验"]
            ),
            TravelEntry(
                title: "巴厘岛度假",
                destination: "印度尼西亚巴厘岛",
                startDate: Date().addingTimeInterval(-86400 * 60),
                endDate: Date().addingTimeInterval(-86400 * 55),
                notes: "完美的海滩假期",
                rating: 5,
                tags: ["海滨度假", "休闲放松"]
            ),
            TravelEntry(
                title: "瑞士阿尔卑斯山",
                destination: "瑞士",
                startDate: Date().addingTimeInterval(-86400 * 90),
                endDate: Date().addingTimeInterval(-86400 * 85),
                notes: "壮丽的雪山风景",
                rating: 5,
                tags: ["自然风光", "山地徒步"]
            )
        ]
    }

    // MARK: - Computed Properties

    var uniqueCountries: Int {
        Set(travels.map { $0.destination }).count
    }

    var totalDays: Int {
        travels.reduce(0) { $0 + $1.duration }
    }

    var recentTravels: [TravelEntry] {
        Array(travels.sorted { $0.startDate > $1.startDate }.prefix(5))
    }

    // MARK: - CRUD Operations

    func addTravel(_ travel: TravelEntry) {
        travels.append(travel)
        saveToDisk()
    }

    func updateTravel(_ travel: TravelEntry) {
        if let index = travels.firstIndex(where: { $0.id == travel.id }) {
            travels[index] = travel
            saveToDisk()
        }
    }

    func deleteTravel(_ travel: TravelEntry) {
        travels.removeAll { $0.id == travel.id }
        saveToDisk()
    }

    // MARK: - Persistence

    private func saveToDisk() {
        // TODO: 实现 CoreData 或文件存储
        // 这里先用内存存储
    }

    // MARK: - Statistics

    func getTravelsByYear() -> [Int: [TravelEntry]] {
        Dictionary(grouping: travels) { travel in
            Calendar.current.component(.year, from: travel.startDate)
        }
    }

    func getTravelsByTag() -> [String: [TravelEntry]] {
        var result: [String: [TravelEntry]] = [:]
        for travel in travels {
            for tag in travel.tags {
                result[tag, default: []].append(travel)
            }
        }
        return result
    }

    func getAverageRating() -> Double {
        guard !travels.isEmpty else { return 0 }
        return Double(travels.reduce(0) { $0 + $1.rating }) / Double(travels.count)
    }
}

// MARK: - Preview

#if DEBUG
extension TravelDataController {
    static var preview: TravelDataController = {
        let controller = TravelDataController()
        controller.travels = [
            TravelEntry(
                title: "东京之旅",
                destination: "日本东京",
                startDate: Date().addingTimeInterval(-86400 * 30),
                endDate: Date().addingTimeInterval(-86400 * 25),
                rating: 5,
                tags: ["城市探索"]
            ),
            TravelEntry(
                title: "巴厘岛度假",
                destination: "印度尼西亚",
                startDate: Date().addingTimeInterval(-86400 * 60),
                endDate: Date().addingTimeInterval(-86400 * 55),
                rating: 5,
                tags: ["海滨度假"]
            )
        ]
        return controller
    }()
}
#endif
