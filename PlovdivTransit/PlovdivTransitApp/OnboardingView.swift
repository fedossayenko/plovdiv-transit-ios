import SwiftUI

/// Simple onboarding shown on first launch.
struct OnboardingView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "bus.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("Plovdiv Transit")
                .font(.largeTitle.bold())

            VStack(alignment: .leading, spacing: 20) {
                featureRow(
                    icon: "map.fill",
                    title: "Live Map",
                    description: "See all buses moving in real-time across Plovdiv",
                )
                featureRow(
                    icon: "magnifyingglass",
                    title: "Find Your Stop",
                    description: "Search stops by name or find the nearest ones",
                )
                featureRow(
                    icon: "clock.fill",
                    title: "Departure Times",
                    description: "Live countdown to your next bus with delay info",
                )
                featureRow(
                    icon: "star.fill",
                    title: "Favorites",
                    description: "Save your frequent stops and lines for quick access",
                )
            }
            .padding(.horizontal, 24)

            Spacer()

            Button {
                isPresented = false
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue, in: .rect(cornerRadius: 14))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
