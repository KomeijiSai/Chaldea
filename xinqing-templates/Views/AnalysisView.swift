//
//  AnalysisView.swift
//  XinQing
//
//  数据分析视图
//  Created by 云眠 on 2026/02/26
//

import SwiftUI
import Charts

struct AnalysisView: View {
    @State private var moodEntries: [MoodEntry] = []
    @State private var selectedTimeRange: TimeRange = .week

    private let calendar = Calendar.current

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 时间范围选择
                    Picker("时间范围", selection: $selectedTimeRange) {
                        Text("本周").tag(TimeRange.week)
                        Text("本月").tag(TimeRange.month)
                        Text("全部").tag(TimeRange.all)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // 情绪趋势图
                    VStack(alignment: .leading, spacing: 12) {
                        Text("情绪趋势")
                            .font(.headline)

                        if filteredEntries.isEmpty {
                            emptyState
                        } else {
                            moodTrendChart
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 2)

                    // 情绪分布
                    VStack(alignment: .leading, spacing: 12) {
                        Text("情绪分布")
                            .font(.headline)

                        if filteredEntries.isEmpty {
                            emptyState
                        } else {
                            moodDistributionChart
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 2)

                    // 情绪洞察
                    VStack(alignment: .leading, spacing: 12) {
                        Text("情绪洞察")
                            .font(.headline)

                        if filteredEntries.isEmpty {
                            emptyState
                        } else {
                            moodInsights
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 2)

                    // 周报
                    if selectedTimeRange == .week {
                        weeklyReport
                    }
                }
                .padding()
            }
            .navigationTitle("数据分析")
            .onAppear {
                loadMoodEntries()
            }
        }
    }

    // MARK: - Components

    private var moodTrendChart: some View {
        Chart(filteredEntries) { entry in
            LineMark(
                x: .value("日期", entry.date, unit: .day),
                y: .value("强度", entry.intensity)
            )
            .foregroundStyle(by: .value("情绪", entry.moodType.rawValue))
            .symbol(by: .value("情绪", entry.moodType.rawValue))
        }
        .frame(height: 200)
        .chartYScale(domain: 1...10)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 1))
        }
    }

    private var moodDistributionChart: some View {
        let moodCounts = Dictionary(grouping: filteredEntries, by: { $0.moodType })
            .mapValues { $0.count }

        return Chart(moodCounts.keys, id: \.self) { mood in
            BarMark(
                x: .value("情绪", mood.rawValue),
                y: .value("次数", moodCounts[mood] ?? 0)
            )
            .foregroundStyle(mood.color)
        }
        .frame(height: 200)
    }

    private var moodInsights: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let mostFrequentMood = getMostFrequentMood() {
                insightRow(
                    icon: "star.fill",
                    title: "最常见情绪",
                    value: "\(mostFrequentMood.emoji) \(mostFrequentMood.rawValue)"
                )
            }

            if let averageIntensity = getAverageIntensity() {
                insightRow(
                    icon: "waveform.path",
                    title: "平均强度",
                    value: String(format: "%.1f/10", averageIntensity)
                )
            }

            if let positiveRatio = getPositiveRatio() {
                insightRow(
                    icon: "heart.fill",
                    title: "正面情绪占比",
                    value: String(format: "%.0f%%", positiveRatio * 100)
                )
            }

            if let streak = getCurrentStreak() {
                insightRow(
                    icon: "flame.fill",
                    title: "连续记录",
                    value: "\(streak) 天"
                )
            }
        }
    }

    private func insightRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 24)

            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }

    private var weeklyReport: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("本周总结")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("📊 本周记录了 \(filteredEntries.count) 次情绪")
                Text("😊 正面情绪占比：\(Int((getPositiveRatio() ?? 0) * 100))%")
                Text("💪 平均强度：\(String(format: "%.1f", getAverageIntensity() ?? 0))/10")

                if let suggestion = getWeeklySuggestion() {
                    Text(suggestion)
                        .padding(.top, 8)
                        .foregroundColor(.accentColor)
                }
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color.accentColor.opacity(0.1))
        .cornerRadius(16)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("📝")
                .font(.system(size: 48))

            Text("还没有数据")
                .font(.headline)

            Text("开始记录你的情绪吧~")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(height: 150)
    }

    // MARK: - Functions

    private func loadMoodEntries() {
        // TODO: 从 CoreData 加载数据
        // 这里使用示例数据
        let today = Date()
        moodEntries = (0..<7).compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { return nil }
            return MoodEntry(
                date: date,
                moodType: MoodType.allCases.randomElement()!,
                intensity: Int.random(in: 3...9),
                tags: ["工作", "学习"].shuffled().prefix(1).map { $0 }
            )
        }
    }

    private var filteredEntries: [MoodEntry] {
        let now = Date()
        switch selectedTimeRange {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            return moodEntries.filter { $0.date >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            return moodEntries.filter { $0.date >= monthAgo }
        case .all:
            return moodEntries
        }
    }

    private func getMostFrequentMood() -> MoodType? {
        let moodCounts = Dictionary(grouping: filteredEntries, by: { $0.moodType })
        return moodCounts.max(by: { $0.value.count < $1.value.count })?.key
    }

    private func getAverageIntensity() -> Double? {
        guard !filteredEntries.isEmpty else { return nil }
        return Double(filteredEntries.map(\.intensity).reduce(0, +)) / Double(filteredEntries.count)
    }

    private func getPositiveRatio() -> Double? {
        guard !filteredEntries.isEmpty else { return nil }
        let positiveCount = filteredEntries.filter { $0.moodType.isPositive }.count
        return Double(positiveCount) / Double(filteredEntries.count)
    }

    private func getCurrentStreak() -> Int? {
        // TODO: 实现连续记录天数计算
        return filteredEntries.count
    }

    private func getWeeklySuggestion() -> String? {
        guard let positiveRatio = getPositiveRatio() else { return nil }

        if positiveRatio >= 0.7 {
            return "💡 本周状态很好！继续保持~"
        } else if positiveRatio >= 0.5 {
            return "💡 本周状态还不错，记得给自己一些放松时间~"
        } else {
            return "💡 本周压力有点大，记得多关注自己的情绪，必要时寻求帮助~"
        }
    }
}

// MARK: - Enums

enum TimeRange: String, CaseIterable {
    case week = "本周"
    case month = "本月"
    case all = "全部"
}

#Preview {
    AnalysisView()
}
