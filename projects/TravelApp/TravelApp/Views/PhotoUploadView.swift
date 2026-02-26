//
//  PhotoUploadView.swift
//  TravelApp
//
//  照片上传和管理界面
//  Created by Sai on 2026-02-26
//

import SwiftUI
import PhotosUI

struct PhotoUploadView: View {
    // MARK: - 环境
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 状态
    @State private var selectedImages: [UIImage] = []
    @State private var showingPhotoPicker = false
    @State private var showingCamera = false
    @State private var uploadedURLs: [String] = []
    @State private var isUploading = false
    @State private var uploadProgress: Double = 0.0
    
    // MARK: - 依赖
    let entryId: UUID
    let photoManager = PhotoManager()
    let onUploadComplete: ([String]) -> Void
    
    // MARK: - 视图
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 选择照片按钮
                    selectionButtons
                    
                    // 已选择照片预览
                    if !selectedImages.isEmpty {
                        selectedPhotosSection
                    }
                    
                    // 上传进度
                    if isUploading {
                        uploadProgressSection
                    }
                    
                    // 已上传照片
                    if !uploadedURLs.isEmpty {
                        uploadedPhotosSection
                    }
                }
                .padding()
            }
            .navigationTitle("照片管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("上传") {
                        uploadPhotos()
                    }
                    .disabled(selectedImages.isEmpty || isUploading)
                }
            }
            .sheet(isPresented: $showingPhotoPicker) {
                PhotoPicker(selectedImages: $selectedImages, maxSelectionCount: 10)
            }
        }
    }
    
    // MARK: - 选择按钮区域
    private var selectionButtons: some View {
        VStack(spacing: 16) {
            Text("选择照片来源")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                Button(action: { showingPhotoPicker = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.largeTitle)
                            .foregroundStyle(.blue)
                        
                        Text("相册")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Button(action: { showingCamera = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.green)
                        
                        Text("相机")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - 已选择照片区域
    private var selectedPhotosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("已选择 (\(selectedImages.count))")
                    .font(.headline)
                
                Spacer()
                
                Button("清空") {
                    selectedImages.removeAll()
                }
                .font(.subheadline)
                .foregroundStyle(.red)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(selectedImages.indices, id: \.self) { index in
                        SelectedPhotoItem(
                            image: selectedImages[index],
                            index: index,
                            onRemove: {
                                selectedImages.remove(at: index)
                            }
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - 上传进度区域
    private var uploadProgressSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("上传中...")
                    .font(.headline)
                
                Spacer()
                
                Text("\(Int(uploadProgress * 100))%")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: uploadProgress, total: 1.0)
                .progressViewStyle(.linear)
                .tint(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - 已上传照片区域
    private var uploadedPhotosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("已上传 (\(uploadedURLs.count))")
                    .font(.headline)
                
                Spacer()
                
                Button("完成") {
                    onUploadComplete(uploadedURLs)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            
            Text("照片已成功上传到游记")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - 辅助方法
    private func uploadPhotos() {
        isUploading = true
        
        Task {
            do {
                let urls = try await photoManager.uploadMultiplePhotos(selectedImages, to: entryId)
                
                await MainActor.run {
                    uploadedURLs = urls
                    isUploading = false
                    selectedImages.removeAll()
                }
            } catch {
                await MainActor.run {
                    isUploading = false
                    // 显示错误
                }
            }
        }
    }
}

// MARK: - 已选择照片项
struct SelectedPhotoItem: View {
    let image: UIImage
    let index: Int
    let onRemove: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .frame(width: 100, height: 100)
                .cornerRadius(8)
                .clipped()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .background(Circle().fill(Color.red))
            }
            .offset(x: 4, y: -4)
        }
    }
}

// MARK: - 照片网格视图
struct PhotoGridView: View {
    let photos: [TravelPhoto]
    let columns: Int
    let onPhotoTap: (TravelPhoto) -> Void
    let onDelete: (TravelPhoto) -> Void
    
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 2), count: columns)
    }
    
    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: 2) {
            ForEach(photos) { photo in
                PhotoGridItem(
                    photo: photo,
                    onTap: { onPhotoTap(photo) },
                    onDelete: { onDelete(photo) }
                )
            }
        }
    }
}

struct PhotoGridItem: View {
    let photo: TravelPhoto
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: photo.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay {
                        ProgressView()
                    }
            }
            .clipped()
            .onTapGesture {
                onTap()
            }
            
            // 标题或位置信息
            if let caption = photo.caption ?? photo.location {
                VStack(alignment: .leading, spacing: 2) {
                    Text(caption)
                        .font(.caption2)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                .padding(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [.black.opacity(0.6), .clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            }
        }
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("删除", systemImage: "trash")
            }
            
            if let caption = photo.caption {
                Button {
                    UIPasteboard.general.string = caption
                } label: {
                    Label("复制描述", systemImage: "doc.on.doc")
                }
            }
        }
    }
}

// MARK: - 预览
#Preview {
    PhotoUploadView(
        entryId: UUID(),
        onUploadComplete: { urls in
            print("Uploaded: \(urls)")
        }
    )
}
