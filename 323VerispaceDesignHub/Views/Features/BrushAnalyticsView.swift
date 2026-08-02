import SwiftUI

struct BrushAnalyticsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.studioTheme) private var theme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                weeklyRecapCard

                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                    spacing: 12
                ) {
                    StatCard(title: "Total Uses", value: "\(store.totalUsageEvents)", icon: "chart.bar.fill")
                    StatCard(title: "Brushes", value: "\(store.brushes.count)", icon: "paintbrush.fill")
                    StatCard(title: "Sessions", value: "\(store.sessionCount)", icon: "clock.fill")
                    StatCard(title: "Streak", value: "\(store.streak)d", icon: "flame.fill")
                }

                StudioCard {
                    ActivityLineChart(points: store.activityLast14Days)
                }

                StudioCard {
                    UsageBarChart(
                        entries: store.usageByBrush.map { entry in
                            let label = String(entry.brush.name.prefix(8))
                            return (label: label, value: entry.count)
                        }
                    )
                }

                StudioCard {
                    ParameterDistributionChart(buckets: store.parameterBuckets)
                }

                StudioCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Averages")
                            .font(.headline)
                            .foregroundStyle(theme.textPrimary)
                        averageRow("Size", String(format: "%.0f pt", store.averageBrushSize))
                        averageRow("Opacity", String(format: "%.0f%%", store.averageBrushOpacity * 100))
                        averageRow("Texture", String(format: "%.0f%%", store.averageBrushTexture * 100))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 100)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var weeklyRecapCard: some View {
        let recap = store.weeklyRecap
        return StudioCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Weekly Recap", systemImage: "calendar")
                    .font(.headline)
                    .foregroundStyle(theme.textPrimary)
                Text("Last 7 days in your studio")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)

                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 12
                ) {
                    recapStat("Created", "\(recap.brushesCreated)")
                    recapStat("Usage", "\(recap.usageEvents)")
                    recapStat("Active days", "\(recap.activeDays)")
                    recapStat("Favorites", "\(recap.favoriteCount)")
                }

                HStack {
                    Text("Top brush")
                        .foregroundStyle(theme.textSecondary)
                    Spacer()
                    Text(recap.topBrushName ?? "—")
                        .fontWeight(.semibold)
                        .foregroundStyle(theme.accent)
                        .lineLimit(1)
                }
                .font(.subheadline)

                HStack {
                    Text("Current streak")
                        .foregroundStyle(theme.textSecondary)
                    Spacer()
                    Text("\(recap.streak) days")
                        .fontWeight(.semibold)
                        .foregroundStyle(theme.primary)
                }
                .font(.subheadline)
            }
        }
    }

    private func recapStat(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(theme.accent)
            Text(title)
                .font(.caption)
                .foregroundStyle(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func averageRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .foregroundStyle(theme.accent)
        }
    }
}
