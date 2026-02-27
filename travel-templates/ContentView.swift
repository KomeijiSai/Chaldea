//
//  ContentView.swift
//  TravelMemoir
//
//  App 主界面
//  Created by 云眠 on 2026/02/27
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataController = TravelDataController.shared
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // 首页 - 旅行记录
            NavigationView {
                HomeView()
            }
            .tabItem {
                Image(systemName: "map.fill")
                Text("首页")
            }
            .tag(0)

            // 地图 - 旅行地图
            NavigationView {
                MapView()
            }
            .tabItem {
                Image(systemName: "globe.asia.australia.fill")
                Text("地图")
            }
            .tag(1)

            // 相册 - 旅行照片
            NavigationView {
                AlbumView()
            }
            .tabItem {
                Image(systemName: "photo.fill")
                Text("相册")
            }
            .tag(2)

            // 统计 - 旅行统计
            NavigationView {
                StatisticsView()
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("统计")
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
    }
}

#Preview {
    ContentView()
}
