import Charts
import SwiftUI

struct UsageBarChart: View {
    let entries: [(label: String, value: Int)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Brush Usage")
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
            if entries.isEmpty {
                Text("Save and use brushes to see analytics.")
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
            } else {
                Chart(Array(entries.prefix(8).enumerated()), id: \.offset) { _, entry in
                    BarMark(
                        x: .value("Brush", entry.label),
                        y: .value("Uses", entry.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color("AppPrimary"), Color("AppAccent")],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(6)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.white.opacity(0.08))
                        AxisValueLabel()
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .frame(height: 180)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ActivityLineChart: View {
    let points: [(day: Date, count: Int)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity (14 days)")
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
            if points.allSatisfy({ $0.count == 0 }) {
                Text("Usage over the next two weeks will appear here.")
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
            } else {
                Chart(points, id: \.day) { point in
                    AreaMark(
                        x: .value("Day", point.day, unit: .day),
                        y: .value("Uses", point.count)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color("AppAccent").opacity(0.45), Color("AppAccent").opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Day", point.day, unit: .day),
                        y: .value("Uses", point.count)
                    )
                    .foregroundStyle(Color("AppAccent"))
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 2.5))

                    PointMark(
                        x: .value("Day", point.day, unit: .day),
                        y: .value("Uses", point.count)
                    )
                    .foregroundStyle(Color("AppPrimary"))
                    .symbolSize(30)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 3)) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.white.opacity(0.06))
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.white.opacity(0.08))
                        AxisValueLabel()
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .frame(height: 180)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ParameterDistributionChart: View {
    let buckets: [(label: String, size: Int, opacity: Int, texture: Int)]

    private struct Row: Identifiable {
        let id: String
        let bucket: String
        let parameter: String
        let count: Int
    }

    private var rows: [Row] {
        buckets.flatMap { bucket in
            [
                Row(id: "\(bucket.label)-size", bucket: bucket.label, parameter: "Size", count: bucket.size),
                Row(id: "\(bucket.label)-opacity", bucket: bucket.label, parameter: "Opacity", count: bucket.opacity),
                Row(id: "\(bucket.label)-texture", bucket: bucket.label, parameter: "Texture", count: bucket.texture)
            ]
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Parameter Mix")
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
            if rows.allSatisfy({ $0.count == 0 }) {
                Text("Create brushes to compare size, opacity, and texture ranges.")
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
            } else {
                Chart(rows) { row in
                    BarMark(
                        x: .value("Bucket", row.bucket),
                        y: .value("Count", row.count)
                    )
                    .foregroundStyle(by: .value("Parameter", row.parameter))
                    .position(by: .value("Parameter", row.parameter))
                }
                .chartForegroundStyleScale([
                    "Size": Color("AppPrimary"),
                    "Opacity": Color("AppAccent"),
                    "Texture": Color.white.opacity(0.55)
                ])
                .chartLegend(position: .bottom, alignment: .leading)
                .frame(height: 180)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
