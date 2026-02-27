//
//  AddTravelView.swift
//  TravelMemoir
//
//  添加旅行视图
//  Created by 云眠 on 2026/02/27
//

import SwiftUI

struct AddTravelView: View {
    @EnvironmentObject var dataController: TravelDataController
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var notes = ""
    @State private var rating = 5
    @State private var selectedTags: [String] = []

    var body: some View {
        NavigationView {
            Form {
                Section("基本信息") {
                    TextField("旅行标题", text: $title)

                    TextField("目的地", text: $destination)

                    DatePicker("开始日期", selection: $startDate, displayedComponents: .date)

                    DatePicker("结束日期", selection: $endDate, displayedComponents: .date)
                }

                Section("评分") {
                    HStack {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= rating ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .font(.title2)
                                .onTapGesture {
                                    rating = index
                                }
                        }
                    }
                }

                Section("标签") {
                    FlowLayout(spacing: 8) {
                        ForEach(TravelTag.allCases, id: \.rawValue) { tag in
                            Text(tag.rawValue)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedTags.contains(tag.rawValue) ? Color.accentColor : Color(.systemGray5))
                                .foregroundColor(selectedTags.contains(tag.rawValue) ? .white : .primary)
                                .cornerRadius(16)
                                .onTapGesture {
                                    if selectedTags.contains(tag.rawValue) {
                                        selectedTags.removeAll { $0 == tag.rawValue }
                                    } else {
                                        selectedTags.append(tag.rawValue)
                                    }
                                }
                        }
                    }
                }

                Section("笔记") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("添加旅行")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveTravel()
                    }
                    .disabled(title.isEmpty || destination.isEmpty)
                }
            }
        }
    }

    private func saveTravel() {
        let travel = TravelEntry(
            title: title,
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            notes: notes,
            rating: rating,
            tags: selectedTags
        )

        dataController.addTravel(travel)
        dismiss()
    }
}

#Preview {
    AddTravelView()
        .environmentObject(TravelDataController.preview)
}
