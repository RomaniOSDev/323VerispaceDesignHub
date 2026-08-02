import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let imageName: String

    var body: some View {
        VStack(spacing: 16) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 140)
                .shadow(color: .black.opacity(0.3), radius: 12, y: 6)
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color("AppTextPrimary"))
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .padding(24)
    }
}
