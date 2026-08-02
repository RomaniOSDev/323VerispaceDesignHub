import Foundation
import SwiftUI
import UIKit

enum BrushTag: String, Codable, CaseIterable, Identifiable {
    case custom
    case ink
    case watercolor
    case charcoal
    case marker
    case chalk

    var id: String { rawValue }

    var title: String {
        switch self {
        case .custom: return "Custom"
        case .ink: return "Ink"
        case .watercolor: return "Watercolor"
        case .charcoal: return "Charcoal"
        case .marker: return "Marker"
        case .chalk: return "Chalk"
        }
    }

    var systemImage: String {
        switch self {
        case .custom: return "paintbrush.pointed"
        case .ink: return "pencil.tip"
        case .watercolor: return "drop.fill"
        case .charcoal: return "scribble.variable"
        case .marker: return "highlighter"
        case .chalk: return "pencil.and.outline"
        }
    }
}

struct BrushPreset: Identifiable {
    let id: String
    let title: String
    let tag: BrushTag
    let size: Double
    let opacity: Double
    let texture: Double
    let colorHex: String

    static let all: [BrushPreset] = [
        BrushPreset(id: "ink", title: "Ink", tag: .ink, size: 8, opacity: 0.95, texture: 0.1, colorHex: "1C1C1E"),
        BrushPreset(id: "watercolor", title: "Watercolor", tag: .watercolor, size: 28, opacity: 0.45, texture: 0.7, colorHex: "5B8DEF"),
        BrushPreset(id: "charcoal", title: "Charcoal", tag: .charcoal, size: 22, opacity: 0.8, texture: 0.85, colorHex: "3A3A3C"),
        BrushPreset(id: "marker", title: "Marker", tag: .marker, size: 16, opacity: 0.9, texture: 0.2, colorHex: "FF6B4A"),
        BrushPreset(id: "chalk", title: "Chalk", tag: .chalk, size: 20, opacity: 0.7, texture: 0.95, colorHex: "F2F2F7")
    ]
}

struct BrushItem: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var size: Double
    var opacity: Double
    var texture: Double
    var createdAt: Date
    var usageCount: Int
    var isFavorite: Bool
    var tag: BrushTag
    var colorHex: String

    init(
        id: UUID = UUID(),
        name: String,
        size: Double,
        opacity: Double,
        texture: Double,
        createdAt: Date = Date(),
        usageCount: Int = 0,
        isFavorite: Bool = false,
        tag: BrushTag = .custom,
        colorHex: String = "59BB75"
    ) {
        self.id = id
        self.name = name
        self.size = size
        self.opacity = opacity
        self.texture = texture
        self.createdAt = createdAt
        self.usageCount = usageCount
        self.isFavorite = isFavorite
        self.tag = tag
        self.colorHex = colorHex
    }

    var strokeColor: Color {
        Color(hex: colorHex) ?? Color("AppAccent")
    }

    enum CodingKeys: String, CodingKey {
        case id, name, size, opacity, texture, createdAt, usageCount, isFavorite, tag, colorHex
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        size = try c.decode(Double.self, forKey: .size)
        opacity = try c.decode(Double.self, forKey: .opacity)
        texture = try c.decode(Double.self, forKey: .texture)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        usageCount = try c.decode(Int.self, forKey: .usageCount)
        isFavorite = try c.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        tag = try c.decodeIfPresent(BrushTag.self, forKey: .tag) ?? .custom
        colorHex = try c.decodeIfPresent(String.self, forKey: .colorHex) ?? "59BB75"
    }
}

enum LibrarySort: String, CaseIterable, Identifiable {
    case newest
    case name
    case usage
    case favoritesFirst

    var id: String { rawValue }

    var title: String {
        switch self {
        case .newest: return "Newest"
        case .name: return "Name"
        case .usage: return "Usage"
        case .favoritesFirst: return "Favorites"
        }
    }
}

struct DesignerSnapshot: Equatable {
    var size: Double
    var opacity: Double
    var texture: Double
    var name: String
    var tag: BrushTag
    var colorHex: String
}

extension Color {
    init?(hex: String) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("#") { cleaned.removeFirst() }
        guard cleaned.count == 6, let value = UInt64(cleaned, radix: 16) else { return nil }
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    func toHexString() -> String {
        let ui = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
