//
//  Persistence.swift
//  XinQing
//
//  Created by Sai on 2026/02/27.
//  CoreData 持久化控制器
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    // 用于预览的示例数据
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // 创建示例情绪记录
        for i in 0..<5 {
            let entry = MoodEntry(context: viewContext)
            entry.id = UUID()
            entry.date = Calendar.current.date(byAdding: .day, value: -i, to: Date())
            entry.moodType = MoodType.allCases.randomElement()?.rawValue ?? "开心"
            entry.intensity = Int16.random(in: 1...5)
            entry.tags = ["工作", "学习"].shuffled().prefix(Int.random(in: 0...2)).map { $0 }
            entry.note = "这是第 \(i+1) 条示例记录"
            entry.createdAt = Date()
            entry.updatedAt = Date()
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "XinQing")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                // 在生产环境中，应该妥善处理这个错误
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectMergePolicy
    }
    
    // MARK: - 保存上下文
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("保存失败: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// MARK: - CoreData 操作扩展
extension PersistenceController {
    // 创建新的情绪记录
    func createMoodEntry(
        moodType: MoodType,
        intensity: Int,
        tags: [String] = [],
        note: String? = nil,
        aiSuggestion: String? = nil
    ) -> MoodEntry {
        let context = container.viewContext
        let entry = MoodEntry(context: context)
        
        entry.id = UUID()
        entry.date = Date()
        entry.moodType = moodType.rawValue
        entry.intensity = Int16(intensity)
        entry.tags = tags
        entry.note = note
        entry.aiSuggestion = aiSuggestion
        entry.createdAt = Date()
        entry.updatedAt = Date()
        
        save()
        
        return entry
    }
    
    // 获取指定日期范围的情绪记录
    func fetchMoodEntries(from startDate: Date, to endDate: Date) -> [MoodEntry] {
        let context = container.viewContext
        let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        
        request.predicate = NSPredicate(
            format: "date >= %@ AND date <= %@",
            startDate as NSDate,
            endDate as NSDate
        )
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MoodEntry.date, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("获取情绪记录失败: \(error)")
            return []
        }
    }
    
    // 获取今天的情绪记录
    func fetchTodayMoodEntries() -> [MoodEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return fetchMoodEntries(from: startOfDay, to: endOfDay)
    }
    
    // 获取最近 7 天的情绪记录
    func fetchRecentWeekMoodEntries() -> [MoodEntry] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
        
        return fetchMoodEntries(from: startDate, to: endDate)
    }
    
    // 删除情绪记录
    func deleteMoodEntry(_ entry: MoodEntry) {
        let context = container.viewContext
        context.delete(entry)
        save()
    }
    
    // 更新情绪记录
    func updateMoodEntry(_ entry: MoodEntry) {
        entry.updatedAt = Date()
        save()
    }
}

// MARK: - 使用示例
/*
 // 在 XinQingApp.swift 中
 @main
 struct XinQingApp: App {
     let persistenceController = PersistenceController.shared
     
     var body: some Scene {
         WindowGroup {
             HomeView()
                 .environment(\.managedObjectContext, persistenceController.container.viewContext)
         }
     }
 }
 
 // 在视图中使用
 @Environment(\.managedObjectContext) private var viewContext
 
 // 创建记录
 let entry = persistenceController.createMoodEntry(
     moodType: .happy,
     intensity: 4,
     tags: ["工作", "学习"],
     note: "今天很充实"
 )
 
 // 获取记录
 let todayEntries = persistenceController.fetchTodayMoodEntries()
 let weekEntries = persistenceController.fetchRecentWeekMoodEntries()
 
 // 删除记录
 persistenceController.deleteMoodEntry(entry)
 */
