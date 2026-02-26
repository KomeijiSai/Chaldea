//
//  TravelEntryDetailView.swift
//  TravelApp
//
//  游记详情页面 UI
//  Created by Sai on 2026-02-26
//

import SwiftUI
import SwiftData

struct TravelEntryDetailView: View {
    // MARK: - 环境
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 状态
    @State private var viewModel: TravelEntryDetailViewModel?
    @State private var isEditing: Bool = false
    @State private var showingPhotoPicker: Bool = false
    @State private var showingAddDay: Bool = false
    
    // MARK: - 数据
    let travelEntry: TravelEntry
    
    // MARK: - 编辑状态
    @State private var editedTitle: String = ""
    @State private var editedContent: String = ""
    
    // MARK: - 视图
    var body: some View {
        Group {
            if let viewModel = viewModel {
                mainContent(viewModel: viewModel)
            } else {
                ProgressView("加载中...")
                    .onAppear {
                        initializeViewModel()
                    }
            }
        }
        .navigationTitle(travelEntry.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "完成" : "编辑") {
                    toggleEditing()
                }
            }
        }
    }
    
    // MARK: - 主内容
    private func mainContent(viewModel: TravelEntryDetailViewModel) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // 封面图
                coverSection
                
                // 基本信息
                infoSection(viewModel: viewModel)
                
                // 标签
                if !travelEntry.tags.isEmpty {
                    tagsSection
                }
                
                // 内容描述
                contentSection(viewModel: viewModel)
                
                // 照片网格
                photosSection(viewModel: viewModel)
                
                // 每日行程
                daysSection(viewModel: viewModel)
            }
            .padding()
        }
    }
    
    // MARK: - 封面区域
    private var coverSection: some View {
        Group {
            if let coverURL = travelEntry.coverImageURL {
                AsyncImage(url: URL(string: coverURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(16/9, contentMode: .fill)
                        .overlay {
                            ProgressView()
                        }
                }
                .cornerRadius(16)
                .clipped()
            }
        }
    }
    
    // MARK: - 信息区域
    private func infoSection(viewModel: TravelEntryDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            if isEditing {
                TextField("游记标题", text: $editedTitle)
                    .font(.title)
                    .bold()
                    .textFieldStyle(.roundedBorder)
            }
            
            // 位置和日期
            HStack(spacing: 16) {
                Label(travelEntry.destination, systemImage: "location.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Label(travelEntry.formattedDateRange, systemImage: "calendar")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Label("\(travelEntry.duration)天", systemImage: "clock.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // 统计信息
            HStack(spacing: 20) {
                StatBadge(icon: "photo.fill", count: viewModel.totalPhotos, label: "照片")
                StatBadge(icon: "book.pages", count: viewModel.totalDays, label: "行程")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - 标签区域
    private var tagsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(travelEntry.tags, id: \.self) { tag in
                    TagView(text: tag)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - 内容区域
    private func contentSection(viewModel: TravelEntryDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("游记描述")
                .font(.headline)
            
            if isEditing {
                TextEditor(text: $editedContent)
                    .frame(minHeight: 100)
                    .textFieldStyle(.roundedBorder)
            } else {
                Text(travelEntry.content.isEmpty ? "暂无描述" : travelEntry.content)
                    .foregroundStyle(travelEntry.content.isEmpty ? .secondary : .primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - 照片区域
    private func photosSection(viewModel: TravelEntryDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("照片 (\(viewModel.totalPhotos))")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { showingPhotoPicker = true }) {
                    Label("添加", systemImage: "plus.circle")
                        .font(.subheadline)
                }
            }
            
            if travelEntry.photos.isEmpty {
                EmptyStateView(
                    icon: "photo.on.rectangle.angled",
                    title: "还没有照片",
                    subtitle: "点击右上角添加照片"
                )
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(travelEntry.photos) { photo in
                        PhotoThumbnailView(photo: photo)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - 行程天数区域
    private func daysSection(viewModel: TravelEntryDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("行程 (\(viewModel.totalDays)天)")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { showingAddDay = true }) {
                    Label("添加", systemImage: "plus.circle")
                        .font(.subheadline)
                }
            }
            
            if travelEntry.days.isEmpty {
                EmptyStateView(
                    icon: "calendar.badge.plus",
                    title: "还没有行程记录",
                    subtitle: "点击右上角添加每日行程"
                )
            } else {
                ForEach(travelEntry.days.sorted(by: { $0.dayNumber < $1.dayNumber })) { day in
                    TravelDayCardView(day: day)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - 辅助方法
    private func initializeViewModel() {
        viewModel = TravelEntryDetailViewModel(
            travelEntry: travelEntry,
            modelContext: modelContext
        )
        editedTitle = travelEntry.title
        editedContent = travelEntry.content
    }
    
    private func toggleEditing() {
        if isEditing {
            // 保存更改
            viewModel?.updateTitle(editedTitle)
            viewModel?.updateContent(editedContent)
        } else {
            // 开始编辑
            editedTitle = travelEntry.title
            editedContent = travelEntry.content
        }
        isEditing.toggle()
    }
}

// MARK: - 辅助视图组件

struct StatBadge: View {
    let icon: String
    let count: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
            
            Text("\(count)")
                .font(.headline)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 60)
        .padding(8)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}

struct TagView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.15))
            .foregroundStyle(.blue)
            .cornerRadius(16)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

struct PhotoThumbnailView: View {
    let photo: TravelPhoto
    
    var body: some View {
        AsyncImage(url: URL(string: photo.imageURL)) { image in
            image
                .resizable()
                .aspectRatio(1, contentMode: .fill)
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .overlay {
                    ProgressView()
                }
        }
        .cornerRadius(8)
        .clipped()
    }
}

struct TravelDayCardView: View {
    let day: TravelDay
    
    var body: some View {
        HStack(spacing: 12) {
            // 天数
            VStack {
                Text("Day")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(day.dayNumber)")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.blue)
            }
            .frame(width: 50)
            
            Divider()
            
            // 内容
            VStack(alignment: .leading, spacing: 4) {
                Text(day.title.isEmpty ? "第\(day.dayNumber)天" : day.title)
                    .font(.headline)
                
                if let location = day.location {
                    Label(location, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if !day.content.isEmpty {
                    Text(day.content)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // 照片数量
            if !day.photos.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "photo.fill")
                        .font(.caption)
                    Text("\(day.photos.count)")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

// MARK: - 预览
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TravelEntry.self, configurations: config)
    
    let entry = TravelEntry(
        title: "京都秋日漫步",
        destination: "日本京都",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
        content: "这是一次难忘的旅程...",
        tags: ["日本", "秋天", "文化"]
    )
    
    return NavigationStack {
        TravelEntryDetailView(travelEntry: entry)
            .modelContainer(container)
    }
}
