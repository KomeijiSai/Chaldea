//
//  DataController.swift
//  XinQing
//
//  CoreData 数据控制器
//  Created by 云眠 on 2026/02/26
//

import Foundation
import CoreData

class DataController: ObservableObject {
    static let shared = DataController()

    let container: NSPersistentContainer

    @Published var moodEntries: [MoodEntry] = []
    @Published var conversations: [Conversation] = []

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "XinQing")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                print("CoreData error: \(error.localizedDescription)")
                return
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        fetchMoodEntries()
        fetchConversations()
    }

    // MARK: - CRUD Operations - MoodEntry

    func createMoodEntry(
        moodType: MoodType,
        intensity: Int,
        tags: [String],
        description: String? = nil
    ) -> MoodEntry {
        let context = container.viewContext
        let entity = MoodEntryEntity(context: context)

        entity.id = UUID()
        entity.date = Date()
        entity.moodType = moodType.rawValue
        entity.intensity = Int16(intensity)
        entity.tags = tags
        entity.entryDescription = description
        entity.createdAt = Date()
        entity.updatedAt = Date()

        saveContext()

        let entry = MoodEntry(
            id: entity.id!,
            date: entity.date!,
            moodType: MoodType(rawValue: entity.moodType!)!,
            intensity: Int(entity.intensity),
            tags: entity.tags ?? [],
            description: entity.entryDescription,
            createdAt: entity.createdAt!,
            updatedAt: entity.updatedAt!
        )

        moodEntries.insert(entry, at: 0)

        return entry
    }

    func fetchMoodEntries() {
        let context = container.viewContext
        let request: NSFetchRequest<MoodEntryEntity> = MoodEntryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MoodEntryEntity.date, ascending: false)]

        do {
            let entities = try context.fetch(request)
            moodEntries = entities.compactMap { entity in
                guard let id = entity.id,
                      let date = entity.date,
                      let moodTypeRaw = entity.moodType,
                      let moodType = MoodType(rawValue: moodTypeRaw),
                      let createdAt = entity.createdAt,
                      let updatedAt = entity.updatedAt else {
                    return nil
                }

                return MoodEntry(
                    id: id,
                    date: date,
                    moodType: moodType,
                    intensity: Int(entity.intensity),
                    tags: entity.tags ?? [],
                    description: entity.entryDescription,
                    aiSuggestion: nil,
                    createdAt: createdAt,
                    updatedAt: updatedAt
                )
            }
        } catch {
            print("Fetch failed: \(error.localizedDescription)")
        }
    }

    func updateMoodEntry(_ entry: MoodEntry, aiSuggestion: String) {
        let context = container.viewContext
        let request: NSFetchRequest<MoodEntryEntity> = MoodEntryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)

        do {
            let entities = try context.fetch(request)
            if let entity = entities.first {
                entity.aiSuggestion = aiSuggestion
                entity.updatedAt = Date()
                saveContext()
            }
        } catch {
            print("Update failed: \(error.localizedDescription)")
        }
    }

    func deleteMoodEntry(_ entry: MoodEntry) {
        let context = container.viewContext
        let request: NSFetchRequest<MoodEntryEntity> = MoodEntryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)

        do {
            let entities = try context.fetch(request)
            if let entity = entities.first {
                context.delete(entity)
                saveContext()
                moodEntries.removeAll { $0.id == entry.id }
            }
        } catch {
            print("Delete failed: \(error.localizedDescription)")
        }
    }

    // MARK: - CRUD Operations - Conversation

    func createConversation(messages: [Message]) -> Conversation {
        let context = container.viewContext
        let entity = ConversationEntity(context: context)

        entity.id = UUID()
        entity.date = Date()
        entity.messages = messages.map { message in
            MessageEntity(context: context)
            // TODO: 实现消息存储
        }
        entity.createdAt = Date()

        saveContext()

        let conversation = Conversation(
            id: entity.id!,
            date: entity.date!,
            messages: messages
        )

        conversations.insert(conversation, at: 0)

        return conversation
    }

    func fetchConversations() {
        // TODO: 实现对话数据获取
    }

    // MARK: - Query Helpers

    func fetchMoodEntries(for date: Date) -> [MoodEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return moodEntries.filter { entry in
            entry.date >= startOfDay && entry.date < endOfDay
        }
    }

    func fetchMoodEntries(from startDate: Date, to endDate: Date) -> [MoodEntry] {
        return moodEntries.filter { entry in
            entry.date >= startDate && entry.date < endDate
        }
    }

    func getMoodStatistics(for timeRange: TimeRange) -> MoodStatistics {
        let entries = getEntriesForTimeRange(timeRange)

        guard !entries.isEmpty else {
            return MoodStatistics.empty
        }

        let moodCounts = Dictionary(grouping: entries, by: { $0.moodType })
            .mapValues { $0.count }

        let averageIntensity = Double(entries.map(\.intensity).reduce(0, +)) / Double(entries.count)

        let positiveCount = entries.filter { $0.moodType.isPositive }.count
        let positiveRatio = Double(positiveCount) / Double(entries.count)

        let mostFrequentMood = moodCounts.max(by: { $0.value < $1.value })?.key

        return MoodStatistics(
            totalEntries: entries.count,
            averageIntensity: averageIntensity,
            positiveRatio: positiveRatio,
            mostFrequentMood: mostFrequentMood,
            moodCounts: moodCounts
        )
    }

    private func getEntriesForTimeRange(_ timeRange: TimeRange) -> [MoodEntry] {
        let now = Date()
        let calendar = Calendar.current

        switch timeRange {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            return fetchMoodEntries(from: weekAgo, to: now)
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            return fetchMoodEntries(from: monthAgo, to: now)
        case .all:
            return moodEntries
        }
    }

    // MARK: - Save & Delete

    func saveContext() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save failed: \(error.localizedDescription)")
            }
        }
    }

    func deleteAllData() {
        let context = container.viewContext

        // Delete all MoodEntry entities
        let moodEntryRequest: NSFetchRequest<NSFetchRequestResult> = MoodEntryEntity.fetchRequest()
        let moodEntryDeleteRequest = NSBatchDeleteRequest(fetchRequest: moodEntryRequest)

        // Delete all Conversation entities
        let conversationRequest: NSFetchRequest<NSFetchRequestResult> = ConversationEntity.fetchRequest()
        let conversationDeleteRequest = NSBatchDeleteRequest(fetchRequest: conversationRequest)

        do {
            try context.execute(moodEntryDeleteRequest)
            try context.execute(conversationDeleteRequest)
            saveContext()

            moodEntries.removeAll()
            conversations.removeAll()
        } catch {
            print("Delete all failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - Models

struct MoodStatistics {
    let totalEntries: Int
    let averageIntensity: Double
    let positiveRatio: Double
    let mostFrequentMood: MoodType?
    let moodCounts: [MoodType: Int]

    static let empty = MoodStatistics(
        totalEntries: 0,
        averageIntensity: 0,
        positiveRatio: 0,
        mostFrequentMood: nil,
        moodCounts: [:]
    )
}

struct Message {
    let id: UUID
    let content: String
    let isFromUser: Bool
    let timestamp: Date
}

struct Conversation {
    let id: UUID
    let date: Date
    let messages: [Message]
}

// MARK: - Preview

#if DEBUG
extension DataController {
    static var preview: DataController = {
        let controller = DataController(inMemory: true)

        // Add sample data
        _ = controller.createMoodEntry(
            moodType: .happy,
            intensity: 8,
            tags: ["工作", "学习"],
            description: "今天完成了很多任务！"
        )

        _ = controller.createMoodEntry(
            moodType: .calm,
            intensity: 6,
            tags: ["家庭"],
            description: "和家人一起度过了愉快的时光"
        )

        return controller
    }()
}
#endif
