import SwiftUI

struct BrushHistoryView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.studioTheme) private var theme

    @State private var search = ""
    @State private var sort: LibrarySort = .newest
    @State private var tagFilter: BrushTag?
    @State private var favoritesOnly = false
    @State private var compareSelection: Set<UUID> = []
    @State private var showCompare = false
    @State private var compareLeft: UUID?
    @State private var compareRight: UUID?

    private var brushes: [BrushItem] {
        store.filteredBrushes(
            search: search,
            sort: sort,
            tag: tagFilter,
            favoritesOnly: favoritesOnly
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls

            if store.brushes.isEmpty {
                EmptyStateView(
                    title: "History is empty",
                    message: "Saved brushes from the designer appear here for editing and reuse.",
                    imageName: "strokeAccent"
                )
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.top, 24)
            } else if brushes.isEmpty {
                Text("No brushes match your filters.")
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
            } else {
                List {
                    ForEach(brushes) { brush in
                        HStack(spacing: 10) {
                            if compareSelection.count > 0 || compareSelection.contains(brush.id) {
                                compareCheckbox(brush.id)
                            }
                            NavigationLink {
                                BrushHistoryDetailView(brush: brush)
                            } label: {
                                historyRow(brush)
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                store.toggleFavorite(id: brush.id)
                            } label: {
                                Label(brush.isFavorite ? "Unfavorite" : "Favorite", systemImage: brush.isFavorite ? "star.slash" : "star.fill")
                            }
                            .tint(theme.accent)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                store.deleteBrush(id: brush.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                store.duplicateBrush(id: brush.id)
                            } label: {
                                Label("Duplicate", systemImage: "plus.square.on.square")
                            }
                            .tint(theme.primary)
                            Button {
                                toggleCompare(brush.id)
                            } label: {
                                Label("Compare", systemImage: "rectangle.split.2x1")
                            }
                            .tint(theme.surface)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationDestination(isPresented: $showCompare) {
            if let compareLeft, let compareRight {
                BrushCompareView(leftID: compareLeft, rightID: compareRight)
            }
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(theme.textSecondary)
                TextField("Search brushes", text: $search)
                    .foregroundStyle(theme.textPrimary)
            }
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(theme.surface.opacity(0.75))
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Menu {
                        ForEach(LibrarySort.allCases) { option in
                            Button(option.title) { sort = option }
                        }
                    } label: {
                        chipLabel(sort.title, systemImage: "arrow.up.arrow.down")
                    }

                    Button {
                        favoritesOnly.toggle()
                        HapticFeedback.selection()
                    } label: {
                        chipLabel("Favorites", systemImage: favoritesOnly ? "star.fill" : "star", active: favoritesOnly)
                    }
                    .buttonStyle(.plain)

                    ForEach(BrushTag.allCases) { tag in
                        Button {
                            tagFilter = tagFilter == tag ? nil : tag
                            HapticFeedback.selection()
                        } label: {
                            chipLabel(tag.title, systemImage: tag.systemImage, active: tagFilter == tag)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }

            if compareSelection.count > 0 {
                HStack {
                    Text("Compare: \(compareSelection.count)/2 selected")
                        .font(.caption)
                        .foregroundStyle(theme.textSecondary)
                    Spacer()
                    Button("Clear") {
                        compareSelection = []
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.textSecondary)
                    Button("Open") {
                        let ids = Array(compareSelection)
                        guard ids.count == 2 else { return }
                        compareLeft = ids[0]
                        compareRight = ids[1]
                        showCompare = true
                    }
                    .font(.caption.weight(.bold))
                    .foregroundStyle(compareSelection.count == 2 ? theme.accent : theme.textSecondary)
                    .disabled(compareSelection.count != 2)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func chipLabel(_ title: String, systemImage: String, active: Bool = false) -> some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundStyle(active ? theme.background : theme.textPrimary)
            .background {
                Capsule()
                    .fill(active ? theme.accent : theme.surface.opacity(0.8))
            }
    }

    private func compareCheckbox(_ id: UUID) -> some View {
        Button {
            toggleCompare(id)
        } label: {
            Image(systemName: compareSelection.contains(id) ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(theme.accent)
        }
        .buttonStyle(.plain)
    }

    private func toggleCompare(_ id: UUID) {
        if compareSelection.contains(id) {
            compareSelection.remove(id)
        } else if compareSelection.count < 2 {
            compareSelection.insert(id)
        } else {
            compareSelection.remove(compareSelection.first!)
            compareSelection.insert(id)
        }
        HapticFeedback.selection()
    }

    private func historyRow(_ brush: BrushItem) -> some View {
        HStack(spacing: 14) {
            BrushPreviewCanvas(
                size: brush.size,
                opacity: brush.opacity,
                texture: brush.texture,
                color: brush.strokeColor
            )
            .frame(width: 88, height: 64)
            .clipped()
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(brush.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(theme.textPrimary)
                    if brush.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(theme.accent)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(brush.tag.title) · Used \(brush.usageCount) times")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(theme.surface.opacity(0.9))
                .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
        }
        .padding(.vertical, 4)
    }
}
