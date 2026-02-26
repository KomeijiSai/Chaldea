//
//  SettingsView.swift
//  XinQing
//
//  设置界面
//  Created by 云眠 on 2026/02/26
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("reminderTime") private var reminderTime = Date()
    @AppStorage("darkMode") private var darkMode = false
    @AppStorage("hapticFeedback") private var hapticFeedback = true

    @State private var showExportSheet = false
    @State private var showAboutSheet = false

    var body: some View {
        NavigationView {
            List {
                // 用户配置
                Section("用户配置") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.title2)
                        
                        TextField("你的名字", text: $userName)
                            .textContentType(.name)
                    }
                }

                // 通知设置
                Section("通知设置") {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("每日提醒", systemImage: "bell.fill")
                    }

                    if notificationsEnabled {
                        DatePicker(
                            "提醒时间",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
                }

                // 外观设置
                Section("外观") {
                    Toggle(isOn: $darkMode) {
                        Label("深色模式", systemImage: "moon.fill")
                    }

                    Toggle(isOn: $hapticFeedback) {
                        Label("触觉反馈", systemImage: "waveform")
                    }
                }

                // 数据管理
                Section("数据管理") {
                    Button(action: { showExportSheet = true }) {
                        Label("导出数据", systemImage: "square.and.arrow.up")
                    }

                    Button(action: exportData) {
                        Label("分享数据", systemImage: "share")
                    }

                    Button(role: .destructive, action: clearData) {
                        Label("清除所有数据", systemImage: "trash")
                    }
                }

                // 关于
                Section("关于") {
                    Button(action: { showAboutSheet = true }) {
                        Label("关于心晴", systemImage: "info.circle")
                    }

                    Link(destination: URL(string: "https://github.com/yourname/xinqing")!) {
                        Label("GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                    }

                    Link(destination: URL(string: "mailto:your@email.com")!) {
                        Label("联系我们", systemImage: "envelope")
                    }

                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }

                // 订阅（后期功能）
                Section("高级功能") {
                    NavigationLink(destination: SubscriptionView()) {
                        Label("升级到 Pro", systemImage: "star.fill")
                    }
                }
            }
            .navigationTitle("设置")
            .sheet(isPresented: $showExportSheet) {
                ExportDataView()
            }
            .sheet(isPresented: $showAboutSheet) {
                AboutView()
            }
        }
    }

    // MARK: - Functions

    private func exportData() {
        // TODO: 实现数据导出
        print("导出数据...")
    }

    private func clearData() {
        // TODO: 实现数据清除
        print("清除数据...")
    }
}

// MARK: - Components

struct ExportDataView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("导出数据")
                    .font(.title)
                    .fontWeight(.bold)

                VStack(spacing: 16) {
                    Button(action: exportAsCSV) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("导出为 CSV")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }

                    Button(action: exportAsPDF) {
                        HStack {
                            Image(systemName: "doc.richtext")
                            Text("导出为 PDF")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }

                    Button(action: exportAsJSON) {
                        HStack {
                            Image(systemName: "curlybraces")
                            Text("导出为 JSON")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding()

                Spacer()
            }
            .padding()
            .navigationTitle("导出数据")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func exportAsCSV() {
        // TODO: 实现 CSV 导出
        print("导出 CSV...")
    }

    private func exportAsPDF() {
        // TODO: 实现 PDF 导出
        print("导出 PDF...")
    }

    private func exportAsJSON() {
        // TODO: 实现 JSON 导出
        print("导出 JSON...")
    }
}

struct AboutView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.accentColor)

                    // 名称
                    Text("心晴")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("AI 心理健康陪伴")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    // 描述
                    VStack(alignment: .leading, spacing: 12) {
                        Text("心晴是一款 AI 心理健康陪伴应用，帮助你每天记录情绪、了解自己。")
                            .font(.body)

                        Text("核心功能:")
                            .font(.headline)
                            .padding(.top)

                        VStack(alignment: .leading, spacing: 8) {
                            featureRow("🎭 情绪记录")
                            featureRow("📅 情绪日历")
                            featureRow("💬 AI 陪伴")
                            featureRow("📊 数据分析")
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)

                    // 版本信息
                    VStack(spacing: 8) {
                        Text("版本 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("© 2026 心晴团队")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("关于心晴")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func featureRow(_ text: String) -> some View {
        HStack(spacing: 8) {
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}

struct SubscriptionView: View {
    @State private var selectedPlan: SubscriptionPlan = .yearly

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)

                    Text("升级到心晴 Pro")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("解锁所有高级功能")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)

                // Features
                VStack(alignment: .leading, spacing: 16) {
                    Text("Pro 功能:")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 12) {
                        proFeature("💎 高级数据分析")
                        proFeature("🧘 个性化冥想音频")
                        proFeature("💬 深度 AI 对话")
                        proFeature("📊 数据导出（PDF/CSV）")
                        proFeature("🚫 无广告体验")
                        proFeature("🔔 优先客服支持")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)

                // Plans
                VStack(spacing: 12) {
                    planCard(.monthly, selected: selectedPlan == .monthly)
                    planCard(.yearly, selected: selectedPlan == .yearly)
                    planCard(.lifetime, selected: selectedPlan == .lifetime)
                }

                // Subscribe Button
                Button(action: subscribe) {
                    Text("立即订阅")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }

                // Restore
                Button("恢复购买") {
                    // TODO: 实现恢复购买
                }
                .font(.caption)
                .foregroundColor(.secondary)

                Text("订阅将自动续费，可随时取消")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("Pro 订阅")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func proFeature(_ text: String) -> some View {
        HStack(spacing: 8) {
            Text(text)
                .font(.subheadline)
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
    }

    private func planCard(_ plan: SubscriptionPlan, selected: Bool) -> some View {
        Button(action: { selectedPlan = plan }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.title)
                        .font(.headline)

                    Text(plan.price)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if plan == .yearly {
                        Text("省 40%")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(8)
                    }
                }

                Spacer()

                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                        .font(.title2)
                }
            }
            .padding()
            .background(selected ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
    }

    private func subscribe() {
        // TODO: 实现订阅
        print("订阅: \(selectedPlan.title)")
    }
}

enum SubscriptionPlan {
    case monthly
    case yearly
    case lifetime

    var title: String {
        switch self {
        case .monthly: return "月订阅"
        case .yearly: return "年订阅"
        case .lifetime: return "终身买断"
        }
    }

    var price: String {
        switch self {
        case .monthly: return "¥18/月"
        case .yearly: return "¥128/年"
        case .lifetime: return "¥298 一次性"
        }
    }
}

#Preview {
    SettingsView()
}
