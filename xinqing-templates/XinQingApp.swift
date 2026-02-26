//
//  XinQingApp.swift
//  XinQing
//
//  App 入口
//  Created by 云眠 on 2026/02/26
//

import SwiftUI

@main
struct XinQingApp: App {
    @StateObject private var dataController = DataController.shared
    @StateObject private var healthKitService = HealthKitService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataController)
                .environmentObject(healthKitService)
                .onAppear {
                    setupApp()
                }
        }
    }

    private func setupApp() {
        // 配置外观
        configureAppearance()

        // 请求 HealthKit 授权（后台）
        Task {
            do {
                try await healthKitService.requestAuthorization()
            } catch {
                print("HealthKit authorization failed: \(error)")
            }
        }
    }

    private func configureAppearance() {
        // 配置 TabBar 外观
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        // 配置 NavigationBar 外观
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }
}
