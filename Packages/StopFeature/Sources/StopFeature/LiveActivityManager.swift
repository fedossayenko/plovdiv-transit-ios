import ActivityKit
import CoreExtensions
import CoreModels
import Foundation
import TransitNetwork

/// Manages Live Activities for bus arrival tracking.
@MainActor
public final class LiveActivityManager {
    public static let shared = LiveActivityManager()

    private var activityId: String?
    private var updateTask: Task<Void, Never>?

    private init() {}

    /// Starts a Live Activity for tracking a departure.
    public func startTracking(
        departure: Departure,
        line: TransitLine?,
        stopId: String,
        stopName: String,
        transitService: TransitService,
    ) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return
        }

        stopTracking()

        let attributes = TransitActivityAttributes(
            lineName: line?.name ?? "?",
            lineColor: line?.color ?? "#0073ac",
            stopName: stopName,
            destination: departure.destination.localized,
        )

        let initialState = TransitActivityAttributes.ContentState(
            minutesUntilArrival: departure.minutesUntil,
            delaySeconds: departure.time.delay,
            scheduledTime: departure.time.scheduled,
        )

        do {
            let content = ActivityContent(
                state: initialState,
                staleDate: Date.now.addingTimeInterval(90),
            )
            let activity = try Activity.request(
                attributes: attributes,
                content: content,
            )
            activityId = activity.id

            startUpdateLoop(
                stopId: stopId,
                lineId: departure.lineId,
                destination: departure.destination.localized,
                transitService: transitService,
            )
        } catch {
            transitLogger.error("Live Activity creation failed: \(error.localizedDescription)")
        }
    }

    /// Stops the current Live Activity.
    public func stopTracking() {
        updateTask?.cancel()
        updateTask = nil

        if let id = activityId {
            endActivity(id: id)
        }
        activityId = nil
    }

    /// Whether a Live Activity is currently running.
    public var isTracking: Bool {
        activityId != nil
    }

    // MARK: - Private

    private func startUpdateLoop(
        stopId: String,
        lineId: String,
        destination: String,
        transitService: TransitService,
    ) {
        updateTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                guard !Task.isCancelled, let self, let activityId else {
                    break
                }

                do {
                    let departures = try await transitService.fetchDepartures(stopId: stopId)
                    if let matching = departures.first(where: {
                        $0.lineId == lineId && $0.destination.localized == destination
                    }) {
                        updateActivity(
                            id: activityId,
                            minutes: matching.minutesUntil,
                            delay: matching.time.delay,
                            scheduled: matching.time.scheduled,
                        )

                        if matching.minutesUntil <= 0 {
                            try? await Task.sleep(for: .seconds(60))
                            stopTracking()
                            break
                        }
                    } else {
                        stopTracking()
                        break
                    }
                } catch {
                    transitLogger.error("Live Activity update failed: \(error.localizedDescription)")
                }
            }
        }
    }

    nonisolated private func endActivity(id: String) {
        Task { @Sendable in
            let content = ActivityContent(
                state: TransitActivityAttributes.ContentState(
                    minutesUntilArrival: 0, delaySeconds: 0, scheduledTime: .now, isActive: false,
                ),
                staleDate: nil,
            )
            for activity in Activity<TransitActivityAttributes>.activities where activity.id == id {
                await activity.end(content, dismissalPolicy: .immediate)
            }
        }
    }

    nonisolated private func updateActivity(
        id: String,
        minutes: Int,
        delay: Double,
        scheduled: Date,
    ) {
        Task { @Sendable in
            let content = ActivityContent(
                state: TransitActivityAttributes.ContentState(
                    minutesUntilArrival: minutes, delaySeconds: delay, scheduledTime: scheduled,
                ),
                staleDate: Date.now.addingTimeInterval(90),
            )
            for activity in Activity<TransitActivityAttributes>.activities where activity.id == id {
                await activity.update(content)
            }
        }
    }
}
