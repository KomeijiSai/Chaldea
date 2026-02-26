//
//  ChatView.swift
//  XinQing
//
//  AI 对话界面
//  Created by 云眠 on 2026/02/26
//

import SwiftUI

struct ChatView: View {
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isTyping = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 对话列表
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if messages.isEmpty {
                                welcomeMessage
                            }

                            ForEach(messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }

                            if isTyping {
                                typingIndicator
                                    .id("typing")
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) { _ in
                        withAnimation {
                            proxy.scrollTo("typing", anchor: .bottom)
                        }
                    }
                }

                Divider()

                // 输入框
                inputBar
            }
            .navigationTitle("AI 陪伴")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            sendWelcomeMessage()
        }
    }

    // MARK: - Components

    private var welcomeMessage: some View {
        VStack(spacing: 16) {
            Text("你好呀~")
                .font(.title)
                .fontWeight(.bold)

            Text("我是心晴，你的 AI 陪伴")
                .font(.body)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 12) {
                Text("我可以帮你：")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    featureRow(icon: "💬", text: "倾听你的心事")
                    featureRow(icon: "💡", text: "提供情绪建议")
                    featureRow(icon: "🧘", text: "引导放松练习")
                    featureRow(icon: "📊", text: "分析情绪模式")
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
        .padding()
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Text(icon)
            Text(text)
                .font(.subheadline)
        }
    }

    private var typingIndicator: some View {
        HStack {
            Text("心晴正在输入...")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            ProgressView()
                .scaleEffect(0.8)
        }
        .padding()
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("和心晴聊聊...", text: $inputText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...5)

            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .font(.title2)
                    .foregroundColor(inputText.isEmpty ? .secondary : .accentColor)
            }
            .disabled(inputText.isEmpty)
        }
        .padding()
    }

    // MARK: - Functions

    private func sendWelcomeMessage() {
        // 发送欢迎消息
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            messages.append(ChatMessage(
                content: "你好呀~ 今天感觉怎么样？",
                isFromUser: false
            ))
        }
    }

    private func sendMessage() {
        guard !inputText.isEmpty else { return }

        let userMessage = ChatMessage(content: inputText, isFromUser: true)
        messages.append(userMessage)
        inputText = ""

        // 模拟 AI 回复
        isTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isTyping = false
            let response = generateResponse(to: userMessage.content)
            messages.append(ChatMessage(content: response, isFromUser: false))
        }
    }

    private func generateResponse(to userMessage: String) -> String {
        // 简单的规则引擎
        let lowercased = userMessage.lowercased()

        if lowercased.contains("开心") || lowercased.contains("高兴") || lowercased.contains("快乐") {
            return "听到你开心，我也很开心呢~ 有什么好事想分享吗？"
        } else if lowercased.contains("难过") || lowercased.contains("伤心") || lowercased.contains("不开心") {
            return "抱歉听到你难过... 想跟我说说发生了什么吗？我会一直在这里陪着你的~"
        } else if lowercased.contains("焦虑") || lowercased.contains("紧张") || lowercased.contains("担心") {
            return "深呼吸~ 焦虑是很正常的情绪。要不要试试 4-7-8 呼吸法？吸气 4 秒，屏息 7 秒，呼气 8 秒~"
        } else if lowercased.contains("压力") || lowercased.contains("累") {
            return "辛苦了~ 记得给自己一些放松的时间。今天有什么特别让你感到压力的事情吗？"
        } else if lowercased.contains("谢谢") || lowercased.contains("感谢") {
            return "不客气~ 能够陪伴你，我也很开心呢！有什么需要随时告诉我~"
        } else if lowercased.contains("晚安") {
            return "晚安~ 祝你有个好梦！记得早点休息哦，明天又是新的一天~ 💕"
        } else if lowercased.contains("你好") || lowercased.contains("hi") || lowercased.contains("嗨") {
            return "你好呀~ 今天想和我聊聊什么呢？"
        } else {
            // 默认回复
            let responses = [
                "嗯嗯，我在听呢~",
                "我理解你的感受~",
                "想多说说吗？我在这里陪你~",
                "这种情况确实不容易呢...",
                "你做得已经很好了~"
            ]
            return responses.randomElement() ?? "我在听呢~"
        }
    }
}

// MARK: - Models

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isFromUser: Bool
    let timestamp = Date()
}

// MARK: - Components

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
            }

            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundColor(message.isFromUser ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(message.isFromUser ? Color.accentColor : Color(.systemGray6))
                    .cornerRadius(16)

                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if !message.isFromUser {
                Spacer()
            }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    ChatView()
}
