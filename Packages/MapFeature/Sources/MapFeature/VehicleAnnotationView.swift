import CoreModels
import SharedUI
import SwiftUI

/// Map annotation for a single vehicle, showing line number and bearing.
struct VehicleAnnotationView: View {
    let vehicle: Vehicle
    let line: TransitLine?

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "arrowtriangle.up.fill")
                .font(.caption2)
                .foregroundStyle(.white)
                .rotationEffect(.degrees(Double(vehicle.bearing)))

            Text(line?.name ?? "?")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white)
                .frame(minWidth: 24, minHeight: 24)
                .background(
                    Color(hex: line?.color ?? "#0073ac"),
                    in: .rect(cornerRadius: 6),
                )
        }
        .opacity(vehicle.speed > 0 ? 1.0 : 0.7)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Bus \(line?.name ?? "unknown"), to \(vehicle.destination.localized), \(vehicle.speed > 0 ? "moving" : "stationary")",
        )
    }
}
