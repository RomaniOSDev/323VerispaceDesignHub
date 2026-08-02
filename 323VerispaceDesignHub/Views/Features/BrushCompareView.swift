import SwiftUI

struct BrushCompareView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.studioTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    let leftID: UUID
    let rightID: UUID

    private var left: BrushItem? { store.brushes.first { $0.id == leftID } }
    private var right: BrushItem? { store.brushes.first { $0.id == rightID } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Compare Brushes")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(theme.textPrimary)

                if let left, let right {
                    HStack(alignment: .top, spacing: 12) {
                        compareCard(left)
                        compareCard(right)
                    }

                    StudioCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Differences")
                                .font(.headline)
                                .foregroundStyle(theme.textPrimary)
                            diffRow("Size", left.size, right.size) { String(format: "%.0f pt", $0) }
                            diffRow("Opacity", left.opacity, right.opacity) { String(format: "%.0f%%", $0 * 100) }
                            diffRow("Texture", left.texture, right.texture) { String(format: "%.0f%%", $0 * 100) }
                            HStack {
                                Text("Color")
                                    .foregroundStyle(theme.textSecondary)
                                Spacer()
                                Circle().fill(left.strokeColor).frame(width: 16, height: 16)
                                Text("vs")
                                    .foregroundStyle(theme.textSecondary)
                                Circle().fill(right.strokeColor).frame(width: 16, height: 16)
                            }
                            .font(.subheadline)
                        }
                    }
                } else {
                    Text("One of the brushes is no longer available.")
                        .foregroundStyle(theme.textSecondary)
                }
            }
            .padding(20)
            .padding(.bottom, 40)
        }
        .studioBackground()
        .navigationTitle("Compare")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
                    .foregroundStyle(theme.accent)
            }
        }
        .onAppear {
            store.markCompareOpened()
        }
    }

    private func compareCard(_ brush: BrushItem) -> some View {
        StudioCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(brush.name)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(theme.textPrimary)
                    .lineLimit(2)
                BrushPreviewCanvas(
                    size: brush.size,
                    opacity: brush.opacity,
                    texture: brush.texture,
                    color: brush.strokeColor
                )
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .clipped()
                Label(brush.tag.title, systemImage: brush.tag.systemImage)
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
                Text("Used \(brush.usageCount)×")
                    .font(.caption2)
                    .foregroundStyle(theme.textSecondary)
                Button {
                    store.applyBrushToDesigner(brush)
                    NotificationCenter.default.post(name: .openDesignerTab, object: nil)
                    dismiss()
                } label: {
                    Text("Open in Designer")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.accent)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func diffRow(_ title: String, _ a: Double, _ b: Double, format: (Double) -> String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(theme.textSecondary)
            Spacer()
            Text(format(a))
                .foregroundStyle(theme.textPrimary)
            Text("→")
                .foregroundStyle(theme.textSecondary)
            Text(format(b))
                .foregroundStyle(theme.textPrimary)
        }
        .font(.subheadline.monospacedDigit())
    }
}
