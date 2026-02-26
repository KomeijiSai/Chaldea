//
//  TravelEntryDetailViewModel.swift
//  TravelApp
//
//  游记详情视图模型
//  Created by Sai on 2026-02-26
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class TravelEntryDetailViewModel {
    
    // MARK: - 属性
    private(set) var travelEntry: TravelEntry
    private let modelContext: ModelContext
    
    var isLoading: Bool = false
    var errorMessage: String?
    
    // MARK: - 初始化
    init(travelEntry: TravelEntry, modelContext: ModelContext) {
        self.travelEntry = travelEntry
        self.modelContext = modelContext
    }
    
    // MARK: - 数据更新
    func updateTitle(_ newTitle: String) {
        travelEntry.title = newTitle
        travelEntry.updatedAt = Date()
        saveChanges()
    }
    
    func updateContent(_ newContent: String) {
        travelEntry.content = newContent
        travelEntry.updatedAt = Date()
        saveChanges()
    }
    
    func updateDateRange(start: Date, end: Date) {
        travelEntry.startDate = start
        travelEntry.endDate = end
        travelEntry.updatedAt = Date()
        saveChanges()
    }
    
    func updateTags(_ newTags: [String]) {
        travelEntry.tags = newTags
        travelEntry.updatedAt = Date()
        saveChanges()
    }
    
    // MARK: - 照片管理
    func addPhoto(_ photo: TravelPhoto) {
        travelEntry.photos.append(photo)
        travelEntry.updatedAt = Date()
        saveChanges()
    }
    
    func removePhoto(at index: Int) {
        guard travelEntry.photos.indices.contains(index) else { return }
        let photo = travelEntry.photos[index]
        modelContext.delete(photo)
        travelEntry.photos.remove(at: index)
        travelEntry.updatedAt = Date()
        saveChanges()
    }
    
    // MARK: - 天数管理
    func addDay(_ day: TravelDay) {
        travelEntry.days.append(day)
        travelEntry.updatedAt = Date()
        saveChanges()
    }
    
    func removeDay(at index: Int) {
        guard travelEntry.days.indices.contains(index) else { return }
        let day = travelEntry.days[index]
        modelContext.delete(day)
        travelEntry.days.remove(at: index)
        travelEntry.updatedAt = Date()
        saveChanges()
    }
    
    func reorderDays(from source: IndexSet, to destination: Int) {
        travelEntry.days.move(fromOffsets: source, toOffset: destination)
        travelEntry.days.enumerated().forEach { index, day in
            day.dayNumber = index + 1
        }
        travelEntry.updatedAt = Date()
        saveChanges()
    }
    
    // MARK: - 辅助方法
    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            errorMessage = "保存失败: \(error.localizedDescription)"
        }
    }
    
    // MARK: - 数据统计
    var totalPhotos: Int {
        travelEntry.photos.count
    }
    
    var totalDays: Int {
        travelEntry.days.count
    }
    
    var photosByLocation: [String: [TravelPhoto]] {
        Dictionary(grouping: travelEntry.photos) { photo in
            photo.location ?? "未知位置"
        }
    }
}
