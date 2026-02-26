//
//  HealthKitService.swift
//  XinQing
//
//  HealthKit 服务
//  Created by 云眠 on 2026/02/26
//

import Foundation
import HealthKit

class HealthKitService: ObservableObject {
    private let healthStore = HKHealthStore()

    @Published var isAuthorized = false
    @Published var heartRateData: [HeartRateData] = []
    @Published var sleepData: [SleepData] = []

    // 需要读取的数据类型
    private let readTypes: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    ]

    // 需要写入的数据类型
    private let writeTypes: Set<HKSampleType> = [
        HKObjectType.categoryType(forIdentifier: .mindfulSession)!
    ]

    // MARK: - Authorization

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if success {
                    Task { @MainActor in
                        self.isAuthorized = true
                    }
                    continuation.resume()
                } else {
                    continuation.resume(throwing: HealthKitError.authorizationDenied)
                }
            }
        }
    }

    // MARK: - Heart Rate

    func fetchHeartRate(for date: Date) async throws -> [HeartRateData] {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )

        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
        ) { _, samples, error in
            if let error = error {
                print("Error fetching heart rate: \(error)")
                return
            }

            guard let samples = samples as? [HKQuantitySample] else { return }

            DispatchQueue.main.async {
                self.heartRateData = samples.map { sample in
                    let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                    let value = sample.quantity.doubleValue(for: heartRateUnit)

                    return HeartRateData(
                        date: sample.startDate,
                        value: value
                    )
                }
            }
        }

        healthStore.execute(query)
        return heartRateData
    }

    func fetchHeartRateSummary(for date: Date) async throws -> HeartRateSummary? {
        let data = try await fetchHeartRate(for: date)

        guard !data.isEmpty else { return nil }

        let values = data.map(\.value)
        let average = values.reduce(0, +) / Double(values.count)
        let max = values.max() ?? 0
        let min = values.min() ?? 0

        return HeartRateSummary(
            date: date,
            average: average,
            max: max,
            min: min,
            count: data.count
        )
    }

    // MARK: - Sleep

    func fetchSleepAnalysis(for date: Date) async throws -> [SleepData] {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )

        let query = HKSampleQuery(
            sampleType: sleepType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
        ) { _, samples, error in
            if let error = error {
                print("Error fetching sleep: \(error)")
                return
            }

            guard let samples = samples as? [HKCategorySample] else { return }

            DispatchQueue.main.async {
                self.sleepData = samples.compactMap { sample in
                    guard let sleepValue = HKCategoryValueSleepAnalysis(rawValue: sample.value) else {
                        return nil
                    }

                    return SleepData(
                        startDate: sample.startDate,
                        endDate: sample.endDate,
                        type: SleepType(from: sleepValue)
                    )
                }
            }
        }

        healthStore.execute(query)
        return sleepData
    }

    func fetchSleepSummary(for date: Date) async throws -> SleepSummary? {
        let data = try await fetchSleepAnalysis(for: date)

        guard !data.isEmpty else { return nil }

        let totalDuration = data.reduce(0.0) { $0 + $1.duration }
        let deepSleepDuration = data.filter { $0.type == .deep }.reduce(0.0) { $0 + $1.duration }
        let lightSleepDuration = data.filter { $0.type == .light }.reduce(0.0) { $0 + $1.duration }
        let remSleepDuration = data.filter { $0.type == .rem }.reduce(0.0) { $0 + $1.duration }

        return SleepSummary(
            date: date,
            totalDuration: totalDuration,
            deepSleepDuration: deepSleepDuration,
            lightSleepDuration: lightSleepDuration,
            remSleepDuration: remSleepDuration
        )
    }

    // MARK: - Mindful Minutes

    func saveMindfulSession(duration: TimeInterval, date: Date = Date()) async throws {
        let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        let sample = HKCategorySample(
            type: mindfulType,
            value: 0,
            start: date,
            end: date.addingTimeInterval(duration)
        )

        try await healthStore.save(sample)
    }
}

// MARK: - Models

struct HeartRateData {
    let date: Date
    let value: Double  // BPM
}

struct HeartRateSummary {
    let date: Date
    let average: Double
    let max: Double
    let min: Double
    let count: Int
}

struct SleepData {
    let startDate: Date
    let endDate: Date
    let type: SleepType

    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
}

struct SleepSummary {
    let date: Date
    let totalDuration: TimeInterval
    let deepSleepDuration: TimeInterval
    let lightSleepDuration: TimeInterval
    let remSleepDuration: TimeInterval
}

enum SleepType {
    case deep
    case light
    case rem
    case awake
    case unknown

    init(from value: HKCategoryValueSleepAnalysis) {
        switch value {
        case .asleepDeep:
            self = .deep
        case .asleepCore:
            self = .light
        case .asleepREM:
            self = .rem
        case .awake:
            self = .awake
        default:
            self = .unknown
        }
    }
}

enum HealthKitError: LocalizedError {
    case notAvailable
    case authorizationDenied
    case dataNotAvailable

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit 不可用"
        case .authorizationDenied:
            return "用户拒绝授权"
        case .dataNotAvailable:
            return "数据不可用"
        }
    }
}

// MARK: - Usage Example

/*
 // 1. 请求授权
 let healthKitService = HealthKitService()
 try await healthKitService.requestAuthorization()

 // 2. 获取心率数据
 let heartRateData = try await healthKitService.fetchHeartRate(for: Date())

 // 3. 获取心率摘要
 let heartRateSummary = try await healthKitService.fetchHeartRateSummary(for: Date())

 // 4. 获取睡眠数据
 let sleepData = try await healthKitService.fetchSleepAnalysis(for: Date())

 // 5. 获取睡眠摘要
 let sleepSummary = try await healthKitService.fetchSleepSummary(for: Date())

 // 6. 保存冥想记录
 try await healthKitService.saveMindfulSession(duration: 300) // 5 分钟
 */
