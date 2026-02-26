//
//  SleepModels.swift
//  SleepApp
//
//  早睡提醒 App 数据模型
//  Created by Sai on 2026-02-26
//

import Foundation
import SwiftData

/// 用户档案模型
@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    var avatar: String?
    var createdAt: Date
    var updatedAt: Date
    
    // 目标作息
    var targetSleepTime: Date // 目标睡眠时间
    var targetWakeTime: Date // 目标起床时间
    var reminderEnabled: Bool
    var reminderMinutesBefore: Int // 提前多少分钟提醒
    
    // 统计数据
    var totalSleepRecords: Int
    var averageSleepTime: TimeInterval
    var streakDays: Int
    
    init(
        name: String,
        targetSleepTime: Date,
        targetWakeTime: Date,
        reminderEnabled: Bool = true,
        reminderMinutesBefore: Int = 30
    ) {
        self.id = UUID()
        self.name = name
        self.targetSleepTime = targetSleepTime
        self.targetWakeTime = targetWakeTime
        self.reminderEnabled = reminderEnabled
        self.reminderMinutesBefore = reminderMinutesBefore
        self.totalSleepRecords = 0
        self.averageSleepTime = 0
        self.streakDays = 0
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

/// 睡眠记录模型
@Model
final class SleepRecord {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var date: Date // 记录日期
    
    // 睡眠时间
    var planSleepTime: Date // 计划睡眠时间
    var actualSleepTime: Date? // 实际睡眠时间
    var planWakeTime: Date // 计划起床时间
    var actualWakeTime: Date? // 实际起床时间
    
    // 睡眠质量
    var sleepQuality: SleepQuality?
    var mood: Mood?
    var notes: String?
    
    // 元数据
    var createdAt: Date
    var updatedAt: Date
    
    init(
        userId: UUID,
        date: Date,
        planSleepTime: Date,
        planWakeTime: Date
    ) {
        self.id = UUID()
        self.userId = userId
        self.date = date
        self.planSleepTime = planSleepTime
        self.planWakeTime = planWakeTime
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // 计算睡眠时长
    var sleepDuration: TimeInterval? {
        guard let sleep = actualSleepTime, let wake = actualWakeTime else {
            return nil
        }
        
        // 处理跨天情况
        if wake < sleep {
            return wake.addingTimeInterval(86400).timeIntervalSince(sleep)
        }
        return wake.timeIntervalSince(sleep)
    }
    
    // 是否按时睡觉
    var isOnTime: Bool? {
        guard let actual = actualSleepTime else { return nil }
        let delay = actual.timeIntervalSince(planSleepTime)
        return delay <= 1800 // 30分钟内算按时
    }
}

/// 睡眠质量枚举
enum SleepQuality: Int, Codable, CaseIterable {
    case terrible = 1
    case poor = 2
    case fair = 3
    case good = 4
    case excellent = 5
    
    var emoji: String {
        switch self {
        case .terrible: return "😫"
        case .poor: return "😕"
        case .fair: return "😐"
        case .good: return "😊"
        case .excellent: return "😴"
        }
    }
    
    var description: String {
        switch self {
        case .terrible: return "很差"
        case .poor: return "较差"
        case .fair: return "一般"
        case .good: return "良好"
        case .excellent: return "优秀"
        }
    }
}

/// 心情枚举
enum Mood: Int, Codable, CaseIterable {
    case exhausted = 1
    case tired = 2
    case normal = 3
    case energetic = 4
    case refreshed = 5
    
    var emoji: String {
        switch self {
        case .exhausted: return "😫"
        case .tired: return "😴"
        case .normal: return "🙂"
        case .energetic: return "😊"
        case .refreshed: return "🤩"
        }
    }
    
    var description: String {
        switch self {
        case .exhausted: return "疲惫"
        case .tired: return "困倦"
        case .normal: return "一般"
        case .energetic: return "精神"
        case .refreshed: return "精力充沛"
        }
    }
}

/// 提醒记录模型
@Model
final class ReminderRecord {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var recordId: UUID
    var scheduledTime: Date
    var sentAt: Date?
    var respondedAt: Date?
    var response: ReminderResponse?
    
    init(userId: UUID, recordId: UUID, scheduledTime: Date) {
        self.id = UUID()
        self.userId = userId
        self.recordId = recordId
        self.scheduledTime = scheduledTime
    }
}

/// 提醒响应枚举
enum ReminderResponse: String, Codable {
    case goingToBed = "去睡了"
    case willBeLate = "晚点睡"
    case ignored = "忽略"
}

/// 共享邀请模型
@Model
final class SharedInvitation {
    @Attribute(.unique) var id: UUID
    var fromUserId: UUID
    var fromUserName: String
    var toUserEmail: String?
    var toUserPhone: String?
    var code: String
    var status: InvitationStatus
    var createdAt: Date
    var acceptedAt: Date?
    
    init(fromUserId: UUID, fromUserName: String, code: String) {
        self.id = UUID()
        self.fromUserId = fromUserId
        self.fromUserName = fromUserName
        self.code = code
        self.status = .pending
        self.createdAt = Date()
    }
}

enum InvitationStatus: String, Codable {
    case pending = "待接受"
    case accepted = "已接受"
    case declined = "已拒绝"
    case expired = "已过期"
}

/// 伴侣关系模型
@Model
final class PartnerRelation {
    @Attribute(.unique) var id: UUID
    var user1Id: UUID
    var user2Id: UUID
    var createdAt: Date
    var isActive: Bool
    
    // 共享设置
    var shareSleepData: Bool
    var shareReminders: Bool
    var notifyPartner: Bool
    
    init(user1Id: UUID, user2Id: UUID) {
        self.id = UUID()
        self.user1Id = user1Id
        self.user2Id = user2Id
        self.createdAt = Date()
        self.isActive = true
        self.shareSleepData = true
        self.shareReminders = true
        self.notifyPartner = true
    }
}
