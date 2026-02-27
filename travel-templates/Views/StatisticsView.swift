//
//  StatisticsView.swift
//  TravelMemoir
//
//  统计视图
//  Created by 云眠 on 2026/02/27
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject var dataController: TravelDataController

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 总览
                overviewSection

                // 年度分布
                yearlyDistributionSection

                // 标签云
                tagCloudSection

                // 评分统计
                ratingDistributionSection
            }
            .padding()
        }
        .navigationTitle("旅行统计")
    }

    // MARK: - Overview Section

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("总览")
                .font(.headline)

            HStack(spacing: 16) {
                StatCard(
                    title: "总旅行",
                    value: "\(dataController.travels.count)",
                    icon: "map.fill",
                    color: .blue
                )

                StatCard(
                    title: "总天数",
                    value: "\(dataController.totalDays)",
                    icon: "calendar",
                    color: .green
                )

                StatCard(
                    title: "平均评分",
                    value: String(format: "%.1f", dataController.getAverageRating()),
                    icon: "star.fill",
                    color: .yellow
                )
            }
        }
    }

    // MARK: - Yearly Distribution Section

    private var yearlyDistributionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("年度分布")
                .font(.headline)

            let travelsByYear = dataController.getTravelsByYear()

            Chart {
                ForEach(Array(travelsByYear.keys.sorted()), id: \.self) { year in
                    BarMark(
                        x: .value("年份", String(year)),
                        y: .value("次数", travelsByYear[year]?.count ?? 0)
                    )
                    .foregroundStyle(.blue)
                }
            }
            .frame(height: 200)
        }
    }

    // MARK: - Tag Cloud Section

    private var tagCloudSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("旅行类型")
                .font(.headline)

            let travelsByTag = dataController.getTravelsByTag()

            FlowLayout(spacing: 8) {
                ForEach(Array(travelsByTag.keys.sorted()), id: \.self) { tag in
                    TagBadge(
                        tag: tag,
                        count: travelsByTag[tag]?.count ?? 0
                    )
                }
            }
        }
    }

    // MARK: - Rating Distribution Section

    private var ratingDistributionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("评分分布")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { rating in
                    let count = dataController.travels.filter { $0.rating == rating }.count

                    VStack {
                        Text("\(count)")
                            .font(.title)
                            .fontWeight(.bold)

                        HStack(spacing: 2) {
                            ForEach(1...rating, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption2)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
    }
}

// MARK: - Components

struct TagBadge: View {
    let tag: String
    let count: Int

    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.subheadline)

            Text("\(count)")
                .font(.caption)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(6)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

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
    NavigationView {
        StatisticsView()
            .environmentObject(TravelDataController.preview)
    }
}
