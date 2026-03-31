import SharedUI
import SwiftUI
import TransitNetwork

#if canImport(FoundationModels)
    import FoundationModels

    /// Chat interface for the on-device transit assistant.
    public struct AssistantChatView: View {
        @Environment(TransitService.self) private var transitService
        @State private var inputText = ""
        @State private var messages: [(role: String, text: String)] = []
        @State private var isProcessing = false
        @State private var assistant: TransitAssistant?

        public init() {}

        public var body: some View {
            NavigationStack {
                VStack(spacing: 0) {
                    // Messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 12) {
                                if messages.isEmpty {
                                    VStack(spacing: 16) {
                                        Image(systemName: "sparkle")
                                            .font(.largeTitle)
                                            .foregroundStyle(.blue)
                                        Text("Ask about Plovdiv transit")
                                            .font(.headline)
                                        Text("Try: \"When does bus 26 come?\" or \"Nearest stops\"")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 60)
                                }

                                ForEach(Array(messages.enumerated()), id: \.offset) { index, message in
                                    MessageBubble(role: message.role, text: message.text)
                                        .id(index)
                                }

                                if isProcessing {
                                    HStack {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        Text("Thinking...")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.horizontal)
                                    .id("processing")
                                }
                            }
                            .padding()
                        }
                        .onChange(of: messages.count) {
                            withAnimation {
                                proxy.scrollTo(messages.count - 1, anchor: .bottom)
                            }
                        }
                    }

                    Divider()

                    // Input
                    HStack(spacing: 12) {
                        TextField("Ask about buses...", text: $inputText)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.send)
                            .onSubmit { sendMessage() }
                            .disabled(isProcessing)

                        Button {
                            sendMessage()
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                        }
                        .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || isProcessing)
                    }
                    .padding()
                }
                .navigationTitle("Transit Assistant")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    if assistant == nil {
                        assistant = TransitAssistant(transitService: transitService)
                    }
                }
            }
        }

        private func sendMessage() {
            let query = inputText.trimmingCharacters(in: .whitespaces)
            guard !query.isEmpty else {
                return
            }

            messages.append((role: "user", text: query))
            inputText = ""
            isProcessing = true

            Task {
                let response = await assistant?.ask(query) ?? "Assistant not available"
                messages.append((role: "assistant", text: response))
                isProcessing = false
            }
        }
    }

    // MARK: - MessageBubble

    private struct MessageBubble: View {
        let role: String
        let text: String

        var body: some View {
            HStack {
                if role == "user" {
                    Spacer(minLength: 60)
                }

                Text(text)
                    .font(.body)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        role == "user" ? Color.accentColor : Color(.systemGray5),
                        in: .rect(cornerRadius: 16),
                    )
                    .foregroundStyle(role == "user" ? .white : .primary)

                if role == "assistant" {
                    Spacer(minLength: 60)
                }
            }
        }
    }

    /// Check if Foundation Models are available on this device.
    @MainActor
    public func isAssistantAvailable() -> Bool {
        TransitAssistant.isAvailable
    }

#else

    /// Fallback for devices without Foundation Models.
    public struct AssistantChatView: View {
        public init() {}

        public var body: some View {
            ContentUnavailableView(
                "Assistant Not Available",
                systemImage: "sparkle",
                description: Text("Requires iPhone with Apple Intelligence enabled"),
            )
        }
    }

    public func isAssistantAvailable() -> Bool {
        false
    }
#endif
