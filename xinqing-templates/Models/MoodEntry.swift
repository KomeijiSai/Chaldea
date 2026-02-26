//
//  MoodEntry.swift
//  XinQing
//
//  Created by Sai on 2026/02/26.
//

import Foundation
import CoreData

// 情绪记录模型
struct MoodEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let moodType: MoodType
    let intensity: Int  // 1-10
    let tags: [String]
    let description: String?
    let aiSuggestion: String?
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        moodType: MoodType,
        intensity: Int,
        tags: [String] = [],
        description: String? = nil,
        aiSuggestion: String? = nil
    ) {
        self.id = id
        self.date = date
        self.moodType = moodType
        self.intensity = max(1, min(10, intensity))  // 限制 1-10
        self.tags = tags
        self.description = description
        self.aiSuggestion = aiSuggestion
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// CoreData 扩展（用于从 CoreData 实体转换）
extension MoodEntry {
    // 从 CoreData 实体创建
    init?(entity: NSManagedObject) {
        guard
            let id = entity.value(forKey: "id") as? UUID,
            let date = entity.value(forKey: "date") as? Date,
            let moodTypeRaw = entity.value(forKey: "moodType") as? String,
            let moodType = MoodType(rawValue: moodTypeRaw),
            let intensity = entity.value(forKey: "intensity") as? Int,
            let createdAt = entity.value(forKey: "createdAt") as? Date,
            let updatedAt = entity.value(forKey: "updatedAt") as? Date
        else {
            return nil
        }
        
        self.id = id
        self.date = date
        self.moodType = moodType
        self.intensity = intensity
        self.tags = entity.value(forKey: "tags") as? [String] ?? []
        self.description = entity.value(forKey: "description") as? String
        self.aiSuggestion = entity.value(forKey: "aiSuggestion") as? String
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
