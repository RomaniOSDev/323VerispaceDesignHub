import SwiftUI

struct DesignerSlider: View {
    @Environment(\.studioTheme) private var theme
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var onEditingChanged: ((Bool) -> Void)? = nil
    let format: (Double) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(theme.textPrimary)
                Spacer()
                Text(format(value))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(theme.accent)
            }
            Slider(value: $value, in: range) { editing in
                onEditingChanged?(editing)
                if !editing {
                    HapticFeedback.selection()
                }
            }
            .tint(theme.primary)
        }
    }
}

struct BrushPreviewCanvas: View {
    @Environment(\.studioTheme) private var theme
    let size: Double
    let opacity: Double
    let texture: Double
    var color: Color? = nil

    private let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)

    var body: some View {
        let stroke = color ?? theme.accent
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            Canvas { context, canvasSize in
                // Keep stroke inside the cell even for large brush sizes.
                let maxStroke = max(canvasSize.height * 0.42, 4)
                let strokeWidth = min(CGFloat(size), maxStroke)
                let insetX = max(strokeWidth * 0.55, canvasSize.width * 0.08)
                var path = Path()
                path.move(to: CGPoint(x: insetX, y: canvasSize.height * 0.55))
                path.addCurve(
                    to: CGPoint(x: canvasSize.width - insetX, y: canvasSize.height * 0.45),
                    control1: CGPoint(x: canvasSize.width * 0.35, y: canvasSize.height * 0.22),
                    control2: CGPoint(x: canvasSize.width * 0.65, y: canvasSize.height * 0.82)
                )
                let jitter = min(CGFloat(texture) * 2.2, canvasSize.height * 0.08)
                for offset in stride(from: -2.0, through: 2.0, by: 1.0) {
                    var layered = path
                    layered = layered.offsetBy(dx: offset * jitter, dy: offset * jitter * 0.5)
                    context.stroke(
                        layered,
                        with: .color(stroke.opacity(opacity * (1 - abs(offset) * 0.15))),
                        style: StrokeStyle(lineWidth: strokeWidth * (1 - abs(offset) * 0.08), lineCap: .round)
                    )
                }
                let dot = min(4.0, canvasSize.height * 0.08)
                context.fill(
                    Path(ellipseIn: CGRect(x: center.x - dot / 2, y: center.y - dot / 2, width: dot, height: dot)),
                    with: .color(theme.primary.opacity(0.6))
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            shape
                .fill(theme.background.opacity(0.6))
                .overlay {
                    shape.stroke(Color.white.opacity(0.08), lineWidth: 1)
                }
        }
        .clipShape(shape)
        .contentShape(shape)
    }
}

struct PracticeCanvas: View {
    @Environment(\.studioTheme) private var theme
    let size: Double
    let opacity: Double
    let texture: Double
    let color: Color
    var onStrokeEnd: (() -> Void)? = nil

    @State private var strokes: [[CGPoint]] = []
    @State private var current: [CGPoint] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Practice Canvas")
                    .font(.headline)
                    .foregroundStyle(theme.textPrimary)
                Spacer()
                Button("Clear") {
                    strokes = []
                    current = []
                    HapticFeedback.lightTap()
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(theme.accent)
            }

            Canvas { context, _ in
                for stroke in strokes + (current.isEmpty ? [] : [current]) {
                    drawStroke(stroke, in: &context)
                }
            }
            .frame(height: 220)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        current.append(value.location)
                    }
                    .onEnded { _ in
                        if current.count > 1 {
                            strokes.append(current)
                            onStrokeEnd?()
                        }
                        current = []
                    }
            )
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(theme.background.opacity(0.55))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Text("Draw freely to feel size, opacity, texture, and color.")
                .font(.caption)
                .foregroundStyle(theme.textSecondary)
        }
    }

    private func drawStroke(_ points: [CGPoint], in context: inout GraphicsContext) {
        guard points.count > 1 else { return }
        var path = Path()
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        let jitter = CGFloat(texture) * 2.5
        for offset in stride(from: -2.0, through: 2.0, by: 1.0) {
            var layered = path
            layered = layered.offsetBy(dx: offset * jitter, dy: offset * jitter * 0.4)
            context.stroke(
                layered,
                with: .color(color.opacity(opacity * (1 - abs(offset) * 0.12))),
                style: StrokeStyle(
                    lineWidth: CGFloat(size) * (1 - abs(offset) * 0.08),
                    lineCap: .round,
                    lineJoin: .round
                )
            )
        }
    }
}

struct StrokeColorPicker: View {
    @Environment(\.studioTheme) private var theme
    @Binding var colorHex: String
    var onWillChange: (() -> Void)? = nil

    private let swatches = ["59BB75", "5B8DEF", "FF6B4A", "F2F2F7", "C084FC", "FBBF24", "1C1C1E", "FF8FAB"]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Stroke Color")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(theme.textPrimary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(swatches, id: \.self) { hex in
                        Button {
                            if colorHex != hex {
                                onWillChange?()
                                colorHex = hex
                                HapticFeedback.selection()
                            }
                        } label: {
                            Circle()
                                .fill(Color(hex: hex) ?? .white)
                                .frame(width: 28, height: 28)
                                .overlay {
                                    Circle()
                                        .stroke(Color.white.opacity(colorHex == hex ? 0.95 : 0.2), lineWidth: colorHex == hex ? 2.5 : 1)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
