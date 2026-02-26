//
//  ContentView.swift
//  XinQing
//
//  App 主界面
//  Created by 云眠 on 2026/02/26
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataController = DataController.shared
    @StateObject private var healthKitService = HealthKitService()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // 首页 - 情绪记录
            NavigationView {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("首页")
            }
            .tag(0)

            // 日历 - 情绪历史
            NavigationView {
                CalendarView()
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("日历")
            }
            .tag(1)

            // 分析 - 数据洞察
            NavigationView {
                AnalysisView()
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("分析")
            }
            .tag(2)

            // AI 对话
            NavigationView {
                ChatView()
            }
            .tabItem {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                Text("对话")
            }
            .tag(3)

            // 设置
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("设置")
            }
            .tag(4)
        }
        .accentColor(.accentColor)
        .environmentObject(dataController)
        .environmentObject(healthKitService)
        .task {
            // 请求 HealthKit 授权
            do {
                try await healthKitService.requestAuthorization()
            } catch {
                print("HealthKit authorization failed: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
