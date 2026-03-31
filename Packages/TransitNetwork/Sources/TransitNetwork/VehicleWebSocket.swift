import Foundation
import CoreModels

/// Manages the WebSocket connection for real-time vehicle positions.
///
/// Connects to `wss://api.livetransport.eu/{cityId}` and streams
/// vehicle position updates as they arrive.
public actor VehicleWebSocket {
    private let url: URL
    private var task: URLSessionWebSocketTask?
    private var continuation: AsyncStream<[Vehicle]>.Continuation?
    private let session: URLSession

    public init(cityId: String = "plovdiv", session: URLSession = .shared) {
        self.url = URL(string: "wss://api.livetransport.eu/\(cityId)")!
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
    }

    // MARK: - Private

    private func receiveLoop() async {
        guard let task else { return }

        while task.state == .running {
            do {
                let message = try await task.receive()
                switch message {
                case .data(let data):
                    let vehicles = try VehicleParser.parseWebSocketMessage(data)
                    continuation?.yield(vehicles)
                case .string(let text):
                    guard let data = text.data(using: .utf8) else { continue }
                    let vehicles = try VehicleParser.parseWebSocketMessage(data)
                    continuation?.yield(vehicles)
                @unknown default:
                    break
                }
            } catch {
                if task.state != .running { break }
                try? await Task.sleep(for: .seconds(2))
            }
        }
    }
}
