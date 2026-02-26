//
//  TravelEntry.swift
//  TravelApp
//
//  旅行游记数据模型
//  Created by Sai on 2026-02-26
//

import Foundation
import SwiftData
import SwiftUI

/// 旅行游记条目模型
@Model
final class TravelEntry {
    // MARK: - 基础属性
    @Attribute(.unique) var id: UUID
    var title: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var createdAt: Date
    var updatedAt: Date
    
    // MARK: - 内容
    var content: String
    var coverImageURL: String?
    
    // MARK: - 关联
    @Relationship(deleteRule: .cascade)
    var photos: [TravelPhoto]
    
    @Relationship(deleteRule: .cascade)
    var days: [TravelDay]
    
    // MARK: - 标签
    var tags: [String]
    
    // MARK: - 初始化
    init(
        title: String,
        destination: String,
        startDate: Date,
        endDate: Date,
        content: String = "",
        coverImageURL: String? = nil,
        tags: [String] = []
    ) {
        self.id = UUID()
        self.title = title
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.content = content
        self.coverImageURL = coverImageURL
        self.tags = tags
        self.photos = []
        self.days = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - 计算属性
    var duration: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0 + 1
    }
    
    var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}

// MARK: - 旅行照片模型
@Model
final class TravelPhoto {
    @Attribute(.unique) var id: UUID
    var imageURL: String
    var caption: String?
    var location: String?
    var takenAt: Date
    var createdAt: Date
    
    init(imageURL: String, caption: String? = nil, location: String? = nil, takenAt: Date = Date()) {
        self.id = UUID()
        self.imageURL = imageURL
        self.caption = caption
        self.location = location
        self.takenAt = takenAt
        self.createdAt = Date()
    }
}

// MARK: - 旅行天数模型
@Model
final class TravelDay {
    @Attribute(.unique) var id: UUID
    var dayNumber: Int
    var date: Date
    var title: String
    var content: String
    var photos: [TravelPhoto]
    var location: String?
    
    init(dayNumber: Int, date: Date, title: String = "", content: String = "", location: String? = nil) {
        self.id = UUID()
        self.dayNumber = dayNumber
        self.date = date
        self.title = title
        self.content = content
        self.photos = []
        self.location = location
    }
}
