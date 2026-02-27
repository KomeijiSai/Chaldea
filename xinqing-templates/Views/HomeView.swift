//
//  HomeView.swift
//  XinQing
//
//  Created by Sai on 2026/02/27.
//  首页 - 情绪记录界面
//

import SwiftUI

struct HomeView: View {
    @State private var selectedMood: MoodType?
    @State private var moodIntensity: Double = 3.0
    @State private var showingMoodPicker = false
    @State private var showingTagPicker = false
    @State private var selectedTags: [String] = []
    
    // 可选的标签
    let availableTags = ["工作", "学习", "家庭", "朋友", "健康", "运动", "睡眠", "饮食", "天气", "其他"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 日期显示
                    dateHeader
                    
                    // 情绪选择器
                    moodSelectionCard
                    
                    // 情绪强度滑块
                    if selectedMood != nil {
                        intensitySlider
                    }
                    
                    // 标签选择
                    if selectedMood != nil {
                        tagSelectionCard
                    }
                    
                    // 保存按钮
                    if selectedMood != nil {
                        saveButton
                    }
                    
                    // 最近记录
                    recentMoodEntries
                }
                .padding()
            }
            .navigationTitle("心晴")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - 日期头部
    private var dateHeader: some View {
        VStack(spacing: 4) {
            Text(formatDate(Date()))
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("今天感觉如何？")
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
    
    // MARK: - 情绪选择卡片
    private var moodSelectionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("选择你的情绪")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                ForEach(MoodType.allCases, id: \.self) { mood in
                    Button(action: {
                        selectedMood = mood
                    }) {
                        VStack(spacing: 8) {
                            Text(mood.emoji)
                                .font(.system(size: 40))
                            
                            Text(mood.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedMood == mood ? mood.color.opacity(0.2) : Color.gray.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedMood == mood ? mood.color : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - 情绪强度滑块
    private var intensitySlider: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("情绪强度")
                    .font(.headline)
                
                Spacer()
                
                Text("\(Int(moodIntensity))/5")
                    .font(.headline)
                    .foregroundColor(selectedMood?.color ?? .accentColor)
            }
            
            Slider(value: $moodIntensity, in: 1...5, step: 1)
                .accentColor(selectedMood?.color ?? .accentColor)
            
            HStack {
                Text("轻微")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("强烈")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        .transition(.opacity.combined(with: .scale))
    }
    
    // MARK: - 标签选择卡片
    private var tagSelectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("添加标签（可选）")
                .font(.headline)
            
            FlowLayout(spacing: 8) {
                ForEach(availableTags, id: \.self) { tag in
                    Button(action: {
                        if selectedTags.contains(tag) {
                            selectedTags.removeAll { $0 == tag }
                        } else {
                            selectedTags.append(tag)
                        }
                    }) {
                        Text(tag)
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedTags.contains(tag) ? (selectedMood?.color ?? .accentColor).opacity(0.2) : Color.gray.opacity(0.1))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(selectedTags.contains(tag) ? (selectedMood?.color ?? .accentColor) : Color.clear, lineWidth: 1)
                            )
                            .foregroundColor(selectedTags.contains(tag) ? (selectedMood?.color ?? .accentColor) : .secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        .transition(.opacity.combined(with: .scale))
    }
    
    // MARK: - 保存按钮
    private var saveButton: some View {
        Button(action: {
            saveMoodEntry()
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("保存记录")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedMood?.color ?? .accentColor)
            .foregroundColor(.white)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
        .transition(.opacity.combined(with: .scale))
    }
    
    // MARK: - 最近记录
    private var recentMoodEntries: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("最近记录")
                    .font(.headline)
                
                Spacer()
                
                Button("查看全部") {
                    // 导航到日历视图
                }
                .font(.subheadline)
                .foregroundColor(.accentColor)
            }
            
            // 这里显示最近 3 条记录
            ForEach(0..<3) { _ in
                HStack(spacing: 12) {
                    Text("😊")
                        .font(.title)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("开心")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("今天 10:30")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("强度: 4")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Helper Functions
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    private func saveMoodEntry() {
        guard let mood = selectedMood else { return }
        
        // TODO: 保存到 CoreData
        print("保存情绪记录: \(mood.rawValue), 强度: \(Int(moodIntensity)), 标签: \(selectedTags)")
        
        // 重置状态
        selectedMood = nil
        moodIntensity = 3.0
        selectedTags = []
    }
}

// MARK: - FlowLayout（流式布局）
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth, currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    HomeView()
}
