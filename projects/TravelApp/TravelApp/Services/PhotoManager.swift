//
//  PhotoManager.swift
//  TravelApp
//
//  照片管理服务 - 处理照片选择、压缩、上传
//  Created by Sai on 2026-02-26
//

import Foundation
import UIKit
import PhotosUI
import SwiftUI

/// 照片管理器
@Observable
class PhotoManager: NSObject {
    
    // MARK: - 属性
    var selectedImages: [UIImage] = []
    var isUploading: Bool = false
    var uploadProgress: Double = 0.0
    var errorMessage: String?
    
    // MARK: - 配置
    private let maxImageWidth: CGFloat = 1920
    private let maxImageHeight: CGFloat = 1080
    private let compressionQuality: CGFloat = 0.8
    private let maxFileSize: Int = 2 * 1024 * 1024 // 2MB
    
    // MARK: - 照片选择
    func selectPhotos(from picker: PHPickerViewController) async throws -> [UIImage] {
        return try await withCheckedThrowingContinuation { continuation in
            var images: [UIImage] = []
            let group = DispatchGroup()
            
            picker.delegate = PhotoPickerDelegate { result in
                switch result {
                case .success(let selectedImages):
                    continuation.resume(returning: selectedImages)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - 照片压缩
    func compressImage(_ image: UIImage) -> UIImage? {
        // 调整尺寸
        let resizedImage = resizeImage(image)
        
        // 压缩质量
        var compression: CGFloat = compressionQuality
        var imageData = resizedImage.jpegData(compressionQuality: compression)
        
        // 逐步降低质量直到满足文件大小要求
        while let data = imageData, data.count > maxFileSize && compression > 0.1 {
            compression -= 0.1
            imageData = resizedImage.jpegData(compressionQuality: compression)
        }
        
        guard let finalData = imageData,
              let compressedImage = UIImage(data: finalData) else {
            return nil
        }
        
        return compressedImage
    }
    
    private func resizeImage(_ image: UIImage) -> UIImage {
        let size = image.size
        
        // 如果图片已经在限制内，直接返回
        if size.width <= maxImageWidth && size.height <= maxImageHeight {
            return image
        }
        
        // 计算新尺寸
        let widthRatio = maxImageWidth / size.width
        let heightRatio = maxImageHeight / size.height
        let ratio = min(widthRatio, heightRatio)
        
        let newSize = CGSize(
            width: size.width * ratio,
            height: size.height * ratio
        )
        
        // 重绘图片
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
    
    // MARK: - 照片上传
    func uploadPhoto(_ image: UIImage, to entryId: UUID) async throws -> String {
        isUploading = true
        uploadProgress = 0.0
        defer {
            isUploading = false
            uploadProgress = 1.0
        }
        
        // 压缩图片
        guard let compressedImage = compressImage(image) else {
            throw PhotoError.compressionFailed
        }
        
        guard let imageData = compressedImage.jpegData(compressionQuality: compressionQuality) else {
            throw PhotoError.invalidImageData
        }
        
        // 保存到本地 Documents 目录
        let fileName = "\(entryId)_\(UUID().uuidString).jpg"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent("photos/\(fileName)")
        
        // 创建目录
        try FileManager.default.createDirectory(
            at: documentsPath.appendingPathComponent("photos"),
            withIntermediateDirectories: true
        )
        
        // 写入文件
        try imageData.write(to: fileURL)
        
        // 返回本地路径
        return fileURL.absoluteString
    }
    
    func uploadMultiplePhotos(_ images: [UIImage], to entryId: UUID) async throws -> [String] {
        var urls: [String] = []
        
        for (index, image) in images.enumerated() {
            uploadProgress = Double(index) / Double(images.count)
            let url = try await uploadPhoto(image, to: entryId)
            urls.append(url)
        }
        
        return urls
    }
    
    // MARK: - 照片删除
    func deletePhoto(at url: String) throws {
        guard let fileURL = URL(string: url) else {
            throw PhotoError.invalidURL
        }
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
    
    // MARK: - 获取照片
    func loadImage(from url: String) -> UIImage? {
        guard let fileURL = URL(string: url),
              FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        return UIImage(contentsOfFile: fileURL.path)
    }
}

// MARK: - PHPicker 代理
class PhotoPickerDelegate: NSObject, PHPickerViewControllerDelegate {
    private let completion: (Result<[UIImage], Error>) -> Void
    
    init(completion: @escaping (Result<[UIImage], Error>) -> Void) {
        self.completion = completion
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        var images: [UIImage] = []
        let group = DispatchGroup()
        
        for result in results {
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                defer { group.leave() }
                
                if let error = error {
                    self.completion(.failure(error))
                    return
                }
                
                if let image = object as? UIImage {
                    images.append(image)
                }
            }
        }
        
        group.notify(queue: .main) {
            self.completion(.success(images))
        }
    }
}

// MARK: - 错误类型
enum PhotoError: LocalizedError {
    case compressionFailed
    case invalidImageData
    case invalidURL
    case uploadFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "照片压缩失败"
        case .invalidImageData:
            return "无效的图片数据"
        case .invalidURL:
            return "无效的URL"
        case .uploadFailed(let message):
            return "上传失败: \(message)"
        }
    }
}

// MARK: - SwiftUI Photo Picker
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    var maxSelectionCount: Int = 10
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = maxSelectionCount
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            var images: [UIImage] = []
            let group = DispatchGroup()
            
            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    defer { group.leave() }
                    
                    if let image = object as? UIImage {
                        images.append(image)
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.parent.selectedImages = images
            }
        }
    }
}
