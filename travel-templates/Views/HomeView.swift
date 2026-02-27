//
//  HomeView.swift
//  TravelMemoir
//
//  首页 - 旅行记录列表
//  Created by 云眠 on 2026/02/27
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataController: TravelDataController
    @State private var showingAddTravel = false
    @State private var searchText = ""

    var filteredTravels: [TravelEntry] {
        if searchText.isEmpty {
            return dataController.travels
        } else {
            return dataController.travels.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.destination.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 统计卡片
                statisticsSection

                // 最近旅行
                recentTravelsSection

                // 所有旅行
                allTravelsSection
            }
            .padding()
        }
        .navigationTitle("我的旅行")
        .searchable(text: $searchText, prompt: "搜索旅行记录")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddTravel = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddTravel) {
            AddTravelView()
        }
    }

    // MARK: - Statistics Section

    private var statisticsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "总旅行",
                value: "\(dataController.travels.count)",
                icon: "map.fill",
                color: .blue
            )

            StatCard(
                title: "国家",
                value: "\(dataController.uniqueCountries)",
                icon: "globe",
                color: .green
            )

            StatCard(
                title: "总天数",
                value: "\(dataController.totalDays)",
                icon: "calendar",
                color: .orange
            )
        }
    }

    // MARK: - Recent Travels Section

    private var recentTravelsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近旅行")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(filteredTravels.prefix(5)) { travel in
                        NavigationLink(destination: TravelDetailView(travel: travel)) {
                            TravelCard(travel: travel)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }

    // MARK: - All Travels Section

    private var allTravelsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("所有旅行")
                .font(.headline)

            LazyVStack(spacing: 12) {
                ForEach(filteredTravels) { travel in
                    NavigationLink(destination: TravelDetailView(travel: travel)) {
                        TravelRow(travel: travel)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

// MARK: - Components

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TravelCard: View {
    let travel: TravelEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 封面图片
            if let coverImage = travel.coverImage {
                AsyncImage(url: URL(string: coverImage)) { image in
                    image.resizable()
                } placeholder: {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.secondary)
                        )
                }
                .aspectRatio(3/4, contentMode: .fill)
                .frame(width: 160, height: 200)
                .cornerRadius(12)
            } else {
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 160, height: 200)
                    .cornerRadius(12)
                    .overlay(
                        VStack {
                            Image(systemName: "map.fill")
                                .font(.largeTitle)
                            Text(travel.destination)
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                    )
            }

            // 信息
            VStack(alignment: .leading, spacing: 4) {
                Text(travel.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(travel.destination)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(formatDateRange(travel.startDate, travel.endDate))
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 160)
    }

    private func formatDateRange(_ start: Date, _ end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}

struct TravelRow: View {
    let travel: TravelEntry

    var body: some View {
        HStack(spacing: 16) {
            // 缩略图
            if let coverImage = travel.coverImage {
                AsyncImage(url: URL(string: coverImage)) { image in
                    image.resizable()
                } placeholder: {
                    Rectangle()
                        .fill(Color(.systemGray5))
                }
                .aspectRatio(1, contentMode: .fill)
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "map.fill")
                            .foregroundColor(.white)
                    )
            }

            // 信息
            VStack(alignment: .leading, spacing: 4) {
                Text(travel.title)
                    .font(.headline)

                Text(travel.destination)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Label("\(travel.duration) 天", systemImage: "calendar")
                    Spacer()
                    Label("\(travel.photos.count) 张", systemImage: "photo")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()

            // 评分
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= travel.rating ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.caption2)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        HomeView()
            .environmentObject(TravelDataController.preview)
    }
}
