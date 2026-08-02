import SwiftUI

struct LibraryContainerView: View {
    @Environment(\.studioTheme) private var theme
    @State private var segment = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Library")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(theme.textPrimary)
                .padding(.horizontal, 20)

            Picker("Library Section", selection: $segment) {
                Text("History").tag(0)
                Text("Statistics").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .onChange(of: segment) { _ in
                HapticFeedback.selection()
            }

            Group {
                if segment == 0 {
                    BrushHistoryView()
                } else {
                    BrushAnalyticsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 12)
    }
}
