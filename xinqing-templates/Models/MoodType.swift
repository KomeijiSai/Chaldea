//
//  MoodType.swift
//  XinQing
//
//  Created by Sai on 2026/02/26.
//

import Foundation
import SwiftUI

// 情绪类型
enum MoodType: String, CaseIterable, Codable {
    case happy = "开心"
    case calm = "平静"
    case anxious = "焦虑"
    case sad = "难过"
    case angry = "愤怒"
    
    // 情绪对应的 emoji
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .calm: return "😌"
        case .anxious: return "😰"
        case .sad: return "😢"
        case .angry: return "😤"
        }
    }
    
    // 情绪对应的颜色
    var color: Color {
        switch self {
        case .happy: return .yellow
        case .calm: return .green
        case .anxious: return .orange
        case .sad: return .blue
        case .angry: return .red
        }
    }
    
    // 情绪是否为正面
    var isPositive: Bool {
        switch self {
        case .happy, .calm: return true
        case .anxious, .sad, .angry: return false
        }
    }
}
