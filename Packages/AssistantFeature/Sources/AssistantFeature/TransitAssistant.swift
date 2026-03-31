import CoreExtensions
import CoreModels
import Foundation
import TransitNetwork

#if canImport(FoundationModels)
    import FoundationModels

    /// On-device transit assistant using Apple Foundation Models.
    @MainActor
    public final class TransitAssistant {
        private let transitService: TransitService
        private var session: LanguageModelSession?

        public init(transitService: TransitService) {
            self.transitService = transitService
        }

        /// Process a natural language query and return a response.
        public func ask(_ query: String) async -> String {
            do {
                if session == nil {
                    session = LanguageModelSession(
                        instructions: """
                        You are a Plovdiv public transit assistant. Help users find bus \
                        schedules, nearby stops, and route information. Be concise. \
                        Respond in the same language as the user's question. \
                        Available data: 29 bus lines, 483 stops in Plovdiv, Bulgaria.
                        """,
                    )
                }

                guard let session else {
                    return "Assistant not ready"
                }

                let context = buildContext()
                let fullQuery = "\(context)\n\nUser question: \(query)"

                let response = try await session.respond(to: fullQuery)
                return response.content
            } catch {
                transitLogger.error("Foundation Models error: \(error.localizedDescription)")
                return "Sorry, I couldn't process your question. Please try again."
            }
        }

        /// Check if Foundation Models are available on this device.
        public static var isAvailable: Bool {
            SystemLanguageModel.default.isAvailable
        }

        // MARK: - Private

        private func buildContext() -> String {
            var parts: [String] = []

            let lineNames = transitService.lines.map(\.name).sorted { a, b in
                (Int(a) ?? 999) < (Int(b) ?? 999)
            }
            parts.append("Active bus lines: \(lineNames.joined(separator: ", "))")
            parts.append("Currently tracking \(transitService.vehicles.count) active vehicles")

            let sampleStops = transitService.stops.prefix(10).map { "\($0.name.en) (code: \($0.code))" }
            parts.append("Sample stops: \(sampleStops.joined(separator: "; "))")

            return parts.joined(separator: "\n")
        }
    }
#endif
