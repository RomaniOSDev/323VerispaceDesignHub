import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: AppStore
    @State private var page = 0

    private let pages: [(title: String, subtitle: String, image: String)] = [
        (
            "Create Custom Brushes",
            "Discover how to design unique digital brushes tailored for your art.",
            "onboardArt"
        ),
        (
            "Design Your Brush",
            "Use the creation tool to build and customize new brush strokes effortlessly.",
            "bannerStudio"
        ),
        (
            "Get Started Now",
            "Start creating your first custom brush with ease.",
            "strokeAccent"
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
                    VStack(spacing: 24) {
                        Image(item.image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: 220)
                            .clipped()
                            .shadow(color: .black.opacity(0.35), radius: 16, y: 8)
                            .padding(.top, 40)
                        VStack(spacing: 12) {
                            Text(item.title)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(Color("AppTextPrimary"))
                                .multilineTextAlignment(.center)
                            Text(item.subtitle)
                                .font(.body)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                        }
                        Spacer(minLength: 0)
                    }
                    .tag(index)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .clearUIKitBackdrop()
            .onChange(of: page) { _ in
                HapticFeedback.selection()
            }

            PrimaryButton(title: page == pages.count - 1 ? "Get Started" : "Continue") {
                if page < pages.count - 1 {
                    withAnimation { page += 1 }
                } else {
                    store.completeOnboarding()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .studioBackground()
    }
}
