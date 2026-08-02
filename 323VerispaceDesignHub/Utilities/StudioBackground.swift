import SwiftUI

struct TransparentUIKitBackdrop: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        DispatchQueue.main.async {
            var node: UIView? = view.superview
            var depth = 0
            while let current = node, depth < 8 {
                if !(current is UIWindow) {
                    current.backgroundColor = .clear
                }
                node = current.superview
                depth += 1
            }
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct StudioBackgroundModifier: ViewModifier {
    @Environment(\.studioTheme) private var theme

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                theme.background
                    .overlay {
                        Image("bgBrush")
                            .resizable()
                            .scaledToFill()
                            .opacity(theme.overlayOpacity)
                            .allowsHitTesting(false)
                    }
                    .clipped()
                    .ignoresSafeArea()
            }
            .background(TransparentUIKitBackdrop())
    }
}

extension View {
    func studioBackground() -> some View {
        modifier(StudioBackgroundModifier())
    }

    func clearUIKitBackdrop() -> some View {
        background(TransparentUIKitBackdrop())
    }
}
