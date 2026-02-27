//
//  CalendarView.swift
//  XinQing
//
//  Created by Sai on 2026/02/27.
//  日历视图 - 显示情绪记录
//

import SwiftUI

struct CalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var moodEntries: [Date: MoodEntry] = [:]
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["日", "一", "二", "三", "四", "五", "六"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 月份导航
                    monthNavigation
                    
                    // 星期标题
                    weekDaysHeader
                    
                    // 日历网格
                    calendarGrid
                    
                    // 选中日期的情绪记录
                    if let entry = moodEntries[calendar.startOfDay(for: selectedDate)] {
                        selectedDayDetail(entry: entry)
                    }
                }
                .padding()
            }
            .navigationTitle("情绪日历")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadMoodEntries()
            }
        }
    }
    
    // MARK: - 月份导航
    private var monthNavigation: some View {
        HStack {
            Button(action: {
                currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                loadMoodEntries()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
            
            Spacer()
            
            Text(monthYearString(from: currentMonth))
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: {
                currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                loadMoodEntries()
            }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - 星期标题
    private var weekDaysHeader: some View {
        HStack(spacing: 0) {
            ForEach(daysOfWeek, id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - 日历网格
    private var calendarGrid: some View {
        let daysInMonth = numberOfDays(in: currentMonth)
        let firstDayOfMonth = firstDay(of: currentMonth)
        let startingSpace = calendar.component(.weekday, from: firstDayOfMonth) - 1
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            // 填充空白格子
            ForEach(0..<startingSpace, id: \.self) { _ in
                Color.clear
                    .frame(height: 50)
            }
            
            // 日期格子
            ForEach(1...daysInMonth, id: \.self) { day in
                if let date = calendar.date(bySetting: .day, value: day, of: currentMonth) {
                    dayCell(for: date)
                }
            }
        }
    }
    
    // MARK: - 日期格子
    private func dayCell(for date: Date) -> some View {
        let day = calendar.component(.day, from: date)
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let entry = moodEntries[calendar.startOfDay(for: date)]
        
        return Button(action: {
            selectedDate = date
        }) {
            VStack(spacing: 4) {
                Text("\(day)")
                    .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isToday ? .accentColor : .primary)
                
                if let moodEntry = entry {
                    let mood = MoodType(rawValue: moodEntry.moodType) ?? .calm
                    Text(mood.emoji)
                        .font(.system(size: 20))
                } else if calendar.isDate(date, equalTo: Date(), toGranularity: .day) == false {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 6, height: 6)
                }
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 选中日期的详情
    private func selectedDayDetail(entry: MoodEntry) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(dateString(from: selectedDate))
                    .font(.headline)
                
                Spacer()
                
                if let mood = MoodType(rawValue: entry.moodType) {
                    Text(mood.emoji)
                        .font(.title)
                }
            }
            
            Divider()
            
            // 情绪信息
            if let mood = MoodType(rawValue: entry.moodType) {
                HStack {
                    Text("情绪:")
                        .foregroundColor(.secondary)
                    
                    Text(mood.rawValue)
                        .fontWeight(.semibold)
                        .foregroundColor(mood.color)
                    
                    Text("强度: \(entry.intensity)/5")
                        .foregroundColor(.secondary)
                }
                .font(.subheadline)
            }
            
            // 标签
            if let tags = entry.tags, !tags.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.gray.opacity(0.1))
                            )
                    }
                }
            }
            
            // 备注
            if let note = entry.note, !note.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("备注:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(note)
                        .font(.subheadline)
                }
            }
            
            // AI 建议
            if let aiSuggestion = entry.aiSuggestion, !aiSuggestion.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.accentColor)
                        
                        Text("AI 建议")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    Text(aiSuggestion)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor.opacity(0.1))
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        .transition(.opacity.combined(with: .scale))
    }
    
    // MARK: - Helper Functions
    private func loadMoodEntries() {
        // 获取当前月份的所有情绪记录
        let startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!
        
        let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        request.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            startDate as NSDate,
            endDate as NSDate
        )
        
        do {
            let entries = try viewContext.fetch(request)
            var entriesDict: [Date: MoodEntry] = [:]
            
            for entry in entries {
                if let date = entry.date {
                    let startOfDay = calendar.startOfDay(for: date)
                    entriesDict[startOfDay] = entry
                }
            }
            
            moodEntries = entriesDict
        } catch {
            print("加载情绪记录失败: \(error)")
        }
    }
    
    private func numberOfDays(in date: Date) -> Int {
        return calendar.range(of: .day, in: .month, for: date)?.count ?? 0
    }
    
    private func firstDay(of date: Date) -> Date {
        return calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 MMMM"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月 d日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

#Preview {
    CalendarView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
