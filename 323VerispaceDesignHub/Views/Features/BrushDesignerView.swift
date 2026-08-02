import SwiftUI

struct BrushDesignerView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.studioTheme) private var theme
    @State private var sliderCheckpoint: DesignerSnapshot?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                challengeBanner
                previewCard
                practiceCard
                presetsRow
                slidersCard
                actionsRow
                saveSection
                savedCollection
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 100)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .scrollDismissesKeyboard(.interactively)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Brush Designer")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(theme.textPrimary)
                Text("Craft strokes with size, opacity, texture, and color")
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
            }
            Spacer()
            HStack(spacing: 8) {
                historyButton(systemImage: "arrow.uturn.backward", enabled: store.canUndo) {
                    store.undoDesigner()
                }
                historyButton(systemImage: "arrow.uturn.forward", enabled: store.canRedo) {
                    store.redoDesigner()
                }
            }
        }
    }

    private var challengeBanner: some View {
        let challenge = store.todayChallenge
        return StudioCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Daily Challenge", systemImage: "flame.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(theme.accent)
                    Spacer()
                    Text(store.isChallengeComplete ? "Done" : "\(store.challengeProgress)/\(challenge.target)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(theme.textSecondary)
                }
                Text(challenge.title)
                    .font(.headline)
                    .foregroundStyle(theme.textPrimary)
                Text(challenge.detail)
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
                ProgressView(value: Double(store.challengeProgress), total: Double(max(challenge.target, 1)))
                    .tint(theme.primary)
            }
        }
    }

    private var previewCard: some View {
        StudioCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Live Preview")
                    .font(.headline)
                    .foregroundStyle(theme.textPrimary)
                BrushPreviewCanvas(
                    size: store.designerSize,
                    opacity: store.designerOpacity,
                    texture: store.designerTexture,
                    color: store.designerStrokeColor
                )
                .frame(height: 160)
            }
        }
    }

    private var practiceCard: some View {
        StudioCard {
            PracticeCanvas(
                size: store.designerSize,
                opacity: store.designerOpacity,
                texture: store.designerTexture,
                color: store.designerStrokeColor
            ) {
                store.recordPracticeStroke()
            }
        }
    }

    private var presetsRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Presets")
                .font(.headline)
                .foregroundStyle(theme.textPrimary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(BrushPreset.all) { preset in
                        Button {
                            store.applyPreset(preset)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Image(systemName: preset.tag.systemImage)
                                    .foregroundStyle(theme.accent)
                                Text(preset.title)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(theme.textPrimary)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(theme.surface.opacity(0.85))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var slidersCard: some View {
        StudioCard {
            VStack(spacing: 18) {
                DesignerSlider(
                    title: "Size",
                    value: $store.designerSize,
                    range: 4...48,
                    onEditingChanged: handleSliderEditing,
                    format: { String(format: "%.0f pt", $0) }
                )
                DesignerSlider(
                    title: "Opacity",
                    value: $store.designerOpacity,
                    range: 0.2...1,
                    onEditingChanged: handleSliderEditing,
                    format: { String(format: "%.0f%%", $0 * 100) }
                )
                DesignerSlider(
                    title: "Texture",
                    value: $store.designerTexture,
                    range: 0...1,
                    onEditingChanged: handleSliderEditing,
                    format: { String(format: "%.0f%%", $0 * 100) }
                )
                StrokeColorPicker(colorHex: $store.designerColorHex) {
                    store.pushDesignerUndo()
                }
                Picker("Tag", selection: $store.designerTag) {
                    ForEach(BrushTag.allCases) { tag in
                        Text(tag.title).tag(tag)
                    }
                }
                .pickerStyle(.menu)
                .tint(theme.accent)
                TextField("Brush name (optional)", text: $store.designerName)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(theme.background.opacity(0.5))
                    }
                    .foregroundStyle(theme.textPrimary)
            }
        }
    }

    private var actionsRow: some View {
        HStack(spacing: 12) {
            Button {
                store.randomizeDesigner()
            } label: {
                Label("Randomize", systemImage: "dice.fill")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(theme.textPrimary)
                    .background {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(theme.surface.opacity(0.9))
                    }
            }
            .buttonStyle(.plain)
        }
    }

    private var saveSection: some View {
        PrimaryButton(title: "Save Brush") {
            store.saveBrushFromDesigner()
        }
    }

    private var savedCollection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Saved Brushes")
                .font(.headline)
                .foregroundStyle(theme.textPrimary)
            if store.brushes.isEmpty {
                EmptyStateView(
                    title: "No brushes yet",
                    message: "Adjust sliders and save your first stroke design.",
                    imageName: "strokeAccent"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(store.brushes.prefix(12)) { brush in
                            savedBrushChip(brush)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private func savedBrushChip(_ brush: BrushItem) -> some View {
        Button {
            store.applyBrushToDesigner(brush)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                BrushPreviewCanvas(
                    size: brush.size,
                    opacity: brush.opacity,
                    texture: brush.texture,
                    color: brush.strokeColor
                )
                .frame(width: 140, height: 90)
                .allowsHitTesting(false)
                HStack {
                    Text(brush.name)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.textPrimary)
                        .lineLimit(1)
                    if brush.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(theme.accent)
                    }
                }
                Text(brush.tag.title)
                    .font(.caption2)
                    .foregroundStyle(theme.textSecondary)
            }
            .padding(10)
            .frame(width: 160, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(theme.surface.opacity(0.85))
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
            }
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.borderless)
    }

    private func historyButton(systemImage: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(enabled ? theme.textPrimary : theme.textSecondary.opacity(0.4))
                .frame(width: 36, height: 36)
                .background {
                    Circle().fill(theme.surface.opacity(0.9))
                }
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    private func handleSliderEditing(_ editing: Bool) {
        if editing {
            sliderCheckpoint = store.designerSnapshot
        } else if let checkpoint = sliderCheckpoint, checkpoint != store.designerSnapshot {
            store.insertUndoSnapshot(checkpoint)
            sliderCheckpoint = nil
        } else {
            sliderCheckpoint = nil
        }
    }
}
