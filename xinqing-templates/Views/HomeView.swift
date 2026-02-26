//
//  HomeView.swift
//  XinQing
//
//  情绪记录界面
//  Created by 云眠 on 2026/02/26
//

import SwiftUI

struct HomeView: View {
    @State private var selectedMood: MoodType?
    @State private var intensity: Double = 5.0
    @State private var selectedTags: Set<String> = []
    @State private var description: String = ""
    @State private var showSuccessMessage = false

    private let availableTags = ["工作", "家庭", "感情", "健康", "金钱", "社交", "学习", "其他"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 日期显示
                    Text(formatDate(Date()))
                        .font(.headline)
                        .foregroundColor(.secondary)

                    // 情绪选择
                    VStack(alignment: .leading, spacing: 12) {
                        Text("今天感觉如何？")
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack(spacing: 12) {
                            ForEach(MoodType.allCases, id: \.self) { mood in
                                MoodButton(
                                    mood: mood,
                                    isSelected: selectedMood == mood
                                ) {
                                    selectedMood = mood
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 2)

                    // 情绪强度
                    if selectedMood != nil {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("情绪强度")
                                .font(.headline)

                            HStack {
                                Text("轻微")
                                Slider(value: $intensity, in: 1...10, step: 1)
                                Text("强烈")
                            }

                            Text("\(Int(intensity))/10")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(selectedMood?.color)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 2)
                    }

                    // 标签选择
                    if selectedMood != nil {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("标签（可选）")
                                .font(.headline)

                            FlowLayout(spacing: 8) {
                                ForEach(availableTags, id: \.self) { tag in
                                    TagButton(
                                        tag: tag,
                                        isSelected: selectedTags.contains(tag)
                                    ) {
                                        if selectedTags.contains(tag) {
                                            selectedTags.remove(tag)
                                        } else {
                                            selectedTags.insert(tag)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 2)
                    }

                    // 描述
                    if selectedMood != nil {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("记录一下（可选）")
                                .font(.headline)

                            TextEditor(text: $description)
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 2)
                    }

                    // 保存按钮
                    if selectedMood != nil {
                        Button(action: saveMoodEntry) {
                            Text("保存")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .cornerRadius(12)
                        }
                        .padding(.top)
                    }
                }
                .padding()
            }
            .navigationTitle("心晴")
            .alert("已记录", isPresented: $showSuccessMessage) {
                Button("好的") {
                    resetForm()
                }
            } message: {
                Text("今天的情绪已记录，继续保持哦~")
            }
        }
    }

    // MARK: - Functions

    private func saveMoodEntry() {
        guard let mood = selectedMood else { return }

        let entry = MoodEntry(
            moodType: mood,
            intensity: Int(intensity),
            tags: Array(selectedTags),
            description: description.isEmpty ? nil : description
        )

        // TODO: 保存到 CoreData
        print("保存情绪记录: \(entry)")

        showSuccessMessage = true
    }

    private func resetForm() {
        selectedMood = nil
        intensity = 5.0
        selectedTags.removeAll()
        description = ""
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 EEEE"
        formatter.locale = Locale(identifier: "zh_Hans_CN")
        return formatter.string(from: date)
    }
}

// MARK: - Components

struct MoodButton: View {
    let mood: MoodType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(mood.emoji)
                    .font(.system(size: 32))
                Text(mood.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(width: 60, height: 70)
            .background(isSelected ? mood.color : Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct TagButton: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// FlowLayout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.reduce(0) { $0 + $1.height + spacing } - spacing
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for item in row.items {
                item.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += item.dimensions(in: .unspecified).width + spacing
            }
            y += row.height + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row()
        var x: CGFloat = 0
        let maxWidth = proposal.width ?? 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if x + size.width > maxWidth && !currentRow.items.isEmpty {
                rows.append(currentRow)
                currentRow = Row()
                x = 0
            }

            currentRow.items.append(subview)
            currentRow.height = max(currentRow.height, size.height)
            x += size.width + spacing
        }

        if !currentRow.items.isEmpty {
            rows.append(currentRow)
        }

        return rows
    }

    struct Row {
        var items: [LayoutSubview] = []
        var height: CGFloat = 0
    }
}

#Preview {
    HomeView()
}
