import CoreModels
import SharedUI
import SwiftUI

/// Row showing a vehicle on a line with destination, delay, and speed.
struct LineVehicleRow: View {
    let vehicle: Vehicle

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(vehicle.destination.localized)
                    .font(TransitTypography.stopName)
                Text(vehicle.id)
                    .font(TransitTypography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            DelayIndicator(delaySeconds: vehicle.delay)

            if vehicle.speed > 0 {
                Text("\(vehicle.speed) km/h")
                    .font(TransitTypography.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.quaternary, in: .capsule)
            }
        }
    }
}
