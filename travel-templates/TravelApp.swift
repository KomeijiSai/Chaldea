//
//  TravelApp.swift
//  TravelMemoir
//
//  App 入口
//  Created by 云眠 on 2026/02/27
//

import SwiftUI

@main
struct TravelApp: App {
    @StateObject private var dataController = TravelDataController.shared
    @StateObject private var locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataController)
                .environmentObject(locationManager)
                .onAppear {
                    setupApp()
                }
        }
    }

    private func setupApp() {
        // 配置外观
        configureAppearance()
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
