//
//  CalendarView.swift
//  XinQing
//
//  情绪日历视图
//  Created by 云眠 on 2026/02/26
//

import SwiftUI

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var displayedMonth = Date()
    @State private var moodEntries: [Date: MoodEntry] = [:]

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 月份导航
                monthNavigation

                // 星期标题
                weekdayHeaders

                // 日历网格
                calendarGrid

                Divider()

                // 选中日期的详情
                selectedDateDetail
            }
            .navigationTitle("情绪日历")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("今天") {
                        selectedDate = Date()
                        displayedMonth = Date()
                    }
                }
            }
        }
        .onAppear {
            loadMoodEntries()
        }
    }

    // MARK: - Components

    private var monthNavigation: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title2)
            }

            Spacer()

            Text(monthYearString(displayedMonth))
                .font(.title2)
                .fontWeight(.bold)

            Spacer()

            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title2)
            }
        }
        .padding()
    }

    private var weekdayHeaders: some View {
        HStack(spacing: 0) {
            ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { weekday in
                Text(weekday)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, 8)
    }

    private var calendarGrid: some View {
        let daysInMonth = numberOfDays(in: displayedMonth)
        let firstWeekday = calendar.component(.weekday, from: startDateOfMonth(displayedMonth)) - 1

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 0) {
            ForEach(0..<firstWeekday, id: \.self) { _ in
                Color.clear
                    .frame(height: 50)
            }

            ForEach(1...daysInMonth, id: \.self) { day in
                if let date = dateFromDay(day) {
                    DayCell(
                        date: date,
                        moodEntry: moodEntries[calendar.startOfDay(for: date)],
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isToday: calendar.isDateInToday(date)
                    ) {
                        selectedDate = date
                    }
                }
            }
        }
        .frame(height: CGFloat(numberOfRows(in: displayedMonth)) * 50)
    }

    @ViewBuilder
    private var selectedDateDetail: some View {
        if let entry = moodEntries[calendar.startOfDay(for: selectedDate)] {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(entry.moodType.emoji)
                        .font(.largeTitle)
                    VStack(alignment: .leading) {
                        Text(entry.moodType.rawValue)
                            .font(.headline)
                        Text("强度: \(entry.intensity)/10")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(dateString(selectedDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if !entry.tags.isEmpty {
                    HStack {
                        ForEach(entry.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }

                if let description = entry.description {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        } else {
            VStack {
                Text("这一天还没有记录")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("点击右上角 + 记录今天的情绪")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }

    // MARK: - Functions

    private func loadMoodEntries() {
        // TODO: 从 CoreData 加载数据
        // 这里使用示例数据
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        moodEntries = [
            today: MoodEntry(moodType: .happy, intensity: 8, tags: ["工作", "学习"], description: "今天完成了很多任务！"),
            yesterday: MoodEntry(moodType: .calm, intensity: 6, tags: ["家庭"], description: "和家人一起度过了愉快的时光")
        ]
    }

    private func previousMonth() {
        displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
    }

    private func nextMonth() {
        displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
    }

    private func monthYearString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter.string(from: date)
    }

    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        return formatter.string(from: date)
    }

    private func numberOfDays(in date: Date) -> Int {
        guard let range = calendar.range(of: .day, in: .month, for: date) else { return 0 }
        return range.count
    }

    private func startDateOfMonth(_ date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }

    private func dateFromDay(_ day: Int) -> Date? {
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        return calendar.date(from: DateComponents(year: components.year, month: components.month, day: day))
    }

    private func numberOfRows(in date: Date) -> Int {
        let days = numberOfDays(in: date)
        let firstWeekday = calendar.component(.weekday, from: startDateOfMonth(date)) - 1
        return Int(ceil(Double(days + firstWeekday) / 7.0))
    }
}

// MARK: - Components

struct DayCell: View {
    let date: Date
    let moodEntry: MoodEntry?
    let isSelected: Bool
    let isToday: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(Color.accentColor.opacity(0.2))
                }

                VStack(spacing: 2) {
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.system(size: 16, weight: isToday ? .bold : .regular))
                        .foregroundColor(isToday ? .accentColor : .primary)

                    if let entry = moodEntry {
                        Circle()
                            .fill(entry.moodType.color)
                            .frame(width: 6, height: 6)
                    }
                }
            }
            .frame(height: 50)
        }
    }
}

#Preview {
    CalendarView()
}
