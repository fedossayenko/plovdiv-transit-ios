import CoreExtensions
import CoreModels
import Foundation

/// Manages the WebSocket connection for real-time vehicle positions.
///
/// Connects to `wss://api.livetransport.eu/{cityId}` and streams
/// vehicle position updates as they arrive.
public actor VehicleWebSocket {
    private let url: URL
    private var task: URLSessionWebSocketTask?
    private var continuation: AsyncStream<[Vehicle]>.Continuation?
    private let session: URLSession
    private var retryDelay: Duration = .seconds(2)
    private static let maxRetryDelay: Duration = .seconds(30)

    public init(cityId: String = "plovdiv", session: URLSession = .shared) {
        guard let wsURL = URL(string: "wss://api.livetransport.eu/\(cityId)") else {
            fatalError("Invalid WebSocket URL for city: \(cityId)")
        }
        url = wsURL
        self.session = session
    }

    /// Returns an AsyncStream of vehicle position arrays.
    /// Each emission contains the full set of currently active vehicles.
    public func connect() -> AsyncStream<[Vehicle]> {
        disconnect()

        let (stream, continuation) = AsyncStream<[Vehicle]>.makeStream()
        self.continuation = continuation

        let task = session.webSocketTask(with: url)
        self.task = task
        task.resume()

        Task { [weak self] in
            await self?.receiveLoop()
        }

        continuation.onTermination = { [weak self] _ in
            Task { await self?.disconnect() }
        }

        return stream
    }

    /// Disconnects the WebSocket.
    public func disconnect() {
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        continuation?.finish()
        continuation = nil
        retryDelay = .seconds(2)
    }

    // MARK: - Private

    private func receiveLoop() async {
        guard let task else {
            return
        }

        while task.state == .running {
            do {
                let message = try await task.receive()
                retryDelay = .seconds(2) // Reset on success
                switch message {
                case let .data(data):
                    let vehicles = try VehicleParser.parseWebSocketMessage(data)
                    continuation?.yield(vehicles)
                case let .string(text):
                    guard let data = text.data(using: .utf8) else {
                        continue
                    }
                    let vehicles = try VehicleParser.parseWebSocketMessage(data)
                    continuation?.yield(vehicles)
                @unknown default:
                    break
                }
            } catch {
                if task.state != .running {
                    break
                }
                let delay = retryDelay
                transitLogger.error("WebSocket error: \(error.localizedDescription), retrying in \(delay)")
                try? await Task.sleep(for: delay)
                retryDelay = min(delay * 2, Self.maxRetryDelay)
            }
        }
    }
}
