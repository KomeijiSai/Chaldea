//
//  MoodPicker.swift
//  XinQing
//
//  Created by Sai on 2026/02/27.
//  可复用的情绪选择器组件
//

import SwiftUI

struct MoodPicker: View {
    @Binding var selectedMood: MoodType?
    let onSelect: ((MoodType) -> Void)?
    
    init(selectedMood: Binding<MoodType?>, onSelect: ((MoodType) -> Void)? = nil) {
        self._selectedMood = selectedMood
        self.onSelect = onSelect
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
            ForEach(MoodType.allCases, id: \.self) { mood in
                MoodButton(
                    mood: mood,
                    isSelected: selectedMood == mood
                ) {
                    selectedMood = mood
                    onSelect?(mood)
                }
            }
        }
    }
}

// MARK: - 情绪按钮
struct MoodButton: View {
    let mood: MoodType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(mood.emoji)
                    .font(.system(size: 40))
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                
                Text(mood.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? mood.color : .secondary)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? mood.color.opacity(0.2) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? mood.color : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 使用示例
/*
 // 方式1: 直接使用 Binding
 @State private var selectedMood: MoodType?
 
 MoodPicker(selectedMood: $selectedMood)
 
 // 方式2: 使用回调
 MoodPicker(selectedMood: $selectedMood) { mood in
     print("选择了: \(mood.rawValue)")
 }
 */

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedMood: MoodType?
        
        var body: some View {
            VStack {
                MoodPicker(selectedMood: $selectedMood) { mood in
                    print("选择了: \(mood.rawValue)")
                }
                
                if let mood = selectedMood {
                    Text("当前选择: \(mood.emoji) \(mood.rawValue)")
                        .font(.headline)
                        .padding()
                }
            }
            .padding()
        }
    }
    
    return PreviewWrapper()
}
