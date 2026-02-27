//
//  SettingsView.swift
//  TravelMemoir
//
//  设置视图
//  Created by 云眠 on 2026/02/27
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkMode") private var darkMode = false

    @State private var showExportSheet = false
    @State private var showAboutSheet = false

    var body: some View {
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

            // 外观设置
            Section("外观") {
                Toggle(isOn: $darkMode) {
                    Label("深色模式", systemImage: "moon.fill")
                }

                Toggle(isOn: $notificationsEnabled) {
                    Label("通知提醒", systemImage: "bell.fill")
                }
            }

            // 数据管理
            Section("数据管理") {
                Button(action: { showExportSheet = true }) {
                    Label("导出数据", systemImage: "square.and.arrow.up")
                }

                Button(role: .destructive, action: clearData) {
                    Label("清除所有数据", systemImage: "trash")
                }
            }

            // 关于
            Section("关于") {
                Button(action: { showAboutSheet = true }) {
                    Label("关于旅行记录", systemImage: "info.circle")
                }

                HStack {
                    Text("版本")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
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

    private func clearData() {
        // TODO: 实现数据清除
        print("清除数据...")
    }
}

struct ExportDataView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("导出数据")
                    .font(.title)
                    .fontWeight(.bold)

                VStack(spacing: 16) {
                    Button(action: exportAsJSON) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("导出为 JSON")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }

                    Button(action: exportAsCSV) {
                        HStack {
                            Image(systemName: "tablecells")
                            Text("导出为 CSV")
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

    private func exportAsJSON() {
        // TODO: 实现 JSON 导出
        print("导出 JSON...")
    }

    private func exportAsCSV() {
        // TODO: 实现 CSV 导出
        print("导出 CSV...")
    }
}

struct AboutView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo
                    Image(systemName: "map.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.accentColor)

                    // 名称
                    Text("旅行记录")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("记录你的每一次冒险")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    // 描述
                    VStack(alignment: .leading, spacing: 12) {
                        Text("旅行记录是一款帮助你记录和管理旅行经历的应用。")

                        Text("核心功能:")
                            .font(.headline)
                            .padding(.top)

                        VStack(alignment: .leading, spacing: 8) {
                            featureRow("🗺️ 旅行地图")
                            featureRow("📸 照片相册")
                            featureRow("📊 统计分析")
                            featureRow("🏷️ 标签管理")
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

                        Text("© 2026 旅行记录团队")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("关于旅行记录")
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

#Preview {
    NavigationView {
        SettingsView()
    }
}
