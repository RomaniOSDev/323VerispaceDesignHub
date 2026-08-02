import SwiftUI

struct BrushHistoryDetailView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.studioTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    @State private var draft: BrushItem

    init(brush: BrushItem) {
        _draft = State(initialValue: brush)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                StudioCard {
                    BrushPreviewCanvas(
                        size: draft.size,
                        opacity: draft.opacity,
                        texture: draft.texture,
                        color: draft.strokeColor
                    )
                    .frame(height: 160)
                }
                StudioCard {
                    VStack(spacing: 16) {
                        TextField("Name", text: $draft.name)
                            .textFieldStyle(.plain)
                            .foregroundStyle(theme.textPrimary)
                        DesignerSlider(title: "Size", value: $draft.size, range: 4...48) {
                            String(format: "%.0f pt", $0)
                        }
                        DesignerSlider(title: "Opacity", value: $draft.opacity, range: 0.2...1) {
                            String(format: "%.0f%%", $0 * 100)
                        }
                        DesignerSlider(title: "Texture", value: $draft.texture, range: 0...1) {
                            String(format: "%.0f%%", $0 * 100)
                        }
                        StrokeColorPicker(colorHex: $draft.colorHex)
                        Picker("Tag", selection: $draft.tag) {
                            ForEach(BrushTag.allCases) { tag in
                                Text(tag.title).tag(tag)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(theme.accent)
                    }
                }

                PrimaryButton(title: "Save Changes") {
                    store.updateBrush(draft)
                    dismiss()
                }

                HStack(spacing: 12) {
                    actionButton(title: draft.isFavorite ? "Unfavorite" : "Favorite", systemImage: draft.isFavorite ? "star.slash.fill" : "star.fill") {
                        store.toggleFavorite(id: draft.id)
                        draft.isFavorite.toggle()
                    }
                    actionButton(title: "Duplicate", systemImage: "plus.square.on.square") {
                        store.duplicateBrush(id: draft.id)
                        dismiss()
                    }
                }

                Button {
                    store.recordBrushUsage(id: draft.id)
                    draft.usageCount = store.brushes.first(where: { $0.id == draft.id })?.usageCount ?? draft.usageCount
                } label: {
                    Text("Record Usage")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(theme.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)

                Button {
                    store.applyBrushToDesigner(draft)
                    NotificationCenter.default.post(name: .openDesignerTab, object: nil)
                    dismiss()
                } label: {
                    Text("Open in Designer")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(theme.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(20)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .scrollDismissesKeyboard(.interactively)
        .studioBackground()
        .navigationTitle("Brush Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onReceive(NotificationCenter.default.publisher(for: .dataReset)) { _ in
            dismiss()
        }
    }

    private func actionButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(theme.textPrimary)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(theme.surface.opacity(0.9))
                }
        }
        .buttonStyle(.plain)
    }
}
