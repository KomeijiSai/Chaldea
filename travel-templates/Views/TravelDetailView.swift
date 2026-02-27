//
//  TravelDetailView.swift
//  TravelMemoir
//
//  旅行详情视图
//  Created by 云眠 on 2026/02/27
//

import SwiftUI

struct TravelDetailView: View {
    let travel: TravelEntry
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 封面图片
                if let coverImage = travel.coverImage {
                    AsyncImage(url: URL(string: coverImage)) { image in
                        image
                            .resizable()
                            .aspectRatio(16/9, contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 200)
                    }
                    .cornerRadius(12)
                }

                // 基本信息
                VStack(alignment: .leading, spacing: 12) {
                    Text(travel.title)
                        .font(.title)
                        .fontWeight(.bold)

                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text(travel.destination)
                    }
                    .foregroundColor(.secondary)

                    HStack {
                        Label(formatDateRange(travel.startDate, travel.endDate), systemImage: "calendar")
                        Spacer()
                        Label("\(travel.duration) 天", systemImage: "clock")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                    // 评分
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= travel.rating ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                        }
                    }
                }
                .padding(.horizontal)

                // 标签
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(travel.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.accentColor.opacity(0.1))
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                }

                // 笔记
                if !travel.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("旅行笔记")
                            .font(.headline)

                        Text(travel.notes)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }

                // 照片
                if !travel.photos.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("照片 (\(travel.photos.count))")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(travel.photos, id: \.self) { photo in
                                    AsyncImage(url: URL(string: photo)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fill)
                                    } placeholder: {
                                        Rectangle()
                                            .fill(Color(.systemGray5))
                                    }
                                    .frame(width: 120, height: 120)
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formatDateRange(_ start: Date, _ end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}

#Preview {
    NavigationView {
        TravelDetailView(travel: TravelDataController.preview.travels[0])
    }
}
