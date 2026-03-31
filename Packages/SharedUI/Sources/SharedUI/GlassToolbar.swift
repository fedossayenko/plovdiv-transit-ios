import SwiftUI

// MARK: - GlassToolbar

/// A floating toolbar with Liquid Glass effect.
/// Glass is only used on the navigation layer (toolbars, buttons) - never on content.
public struct GlassToolbar<Content: View>: View {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        if #available(iOS 26, *) {
            GlassEffectContainer {
                HStack(spacing: 16) {
                    content
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .glassEffect(.regular, in: .capsule)
            }
        } else {
            HStack(spacing: 16) {
                content
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: .capsule)
        }
    }
}

// MARK: - GlassButton

/// A floating action button with Liquid Glass effect.
public struct GlassButton: View {
    let systemImage: String
    let action: () -> Void

    public init(systemImage: String, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.action = action
    }

    public var body: some View {
        if #available(iOS 26, *) {
            Button(action: action) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .frame(width: 44, height: 44)
            }
            .glassEffect(.regular.interactive(), in: .circle)
        } else {
            Button(action: action) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .frame(width: 44, height: 44)
            }
            .background(.ultraThinMaterial, in: .circle)
        }
    }
}
