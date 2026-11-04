// Renders the raster exports from the SVG masters in this folder.
// From the repository root:
//   swiftc docs/brand/export.swift -o /tmp/brand-export && /tmp/brand-export
import AppKit

let brand = "docs/brand"
let appIcon = "IndicaOS/Assets.xcassets/AppIcon.appiconset"

func hex(_ value: UInt32) -> CGColor {
    CGColor(
        srgbRed: CGFloat(value >> 16 & 0xFF) / 255,
        green: CGFloat(value >> 8 & 0xFF) / 255,
        blue: CGFloat(value & 0xFF) / 255,
        alpha: 1
    )
}

/// Reads a master, swapping its colors when a variant isn't kept as its own file.
func svg(_ name: String, replacing swaps: [String: String] = [:]) -> NSImage {
    var text = try! String(contentsOfFile: "\(brand)/\(name).svg", encoding: .utf8)
    for (old, new) in swaps { text = text.replacingOccurrences(of: old, with: new) }
    return NSImage(data: text.data(using: .utf8)!)!
}

/// Writes an opaque PNG: App Store icons must have no alpha channel.
func render(_ path: String, width: Int, height: Int, background: UInt32, draw: (CGRect) -> Void) {
    let context = CGContext(
        data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
        space: CGColorSpace(name: CGColorSpace.sRGB)!,
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
    )!
    let bounds = CGRect(x: 0, y: 0, width: width, height: height)
    context.setFillColor(hex(background))
    context.fill(bounds)
    NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
    draw(bounds)
    NSGraphicsContext.current = nil
    let data = NSBitmapImageRep(cgImage: context.makeImage()!).representation(using: .png, properties: [:])!
    try! data.write(to: URL(fileURLWithPath: path))
}

func centered(_ size: CGSize, in bounds: CGRect) -> CGRect {
    CGRect(x: bounds.midX - size.width / 2, y: bounds.midY - size.height / 2, width: size.width, height: size.height)
}

/// A full-bleed square: the mark at 75% of the tile. iOS and GitHub apply their own corners.
func tile(_ path: String, side: Int, background: UInt32, mark: NSImage) {
    render(path, width: side, height: side, background: background) { bounds in
        let size = CGFloat(side) * 0.75
        mark.draw(in: centered(CGSize(width: size, height: size), in: bounds))
    }
}

let tinted = svg("mark-dark", replacing: ["#ECEEEB": "#FFFFFF", "#FF6A36": "#A0A0A0"])

tile("\(appIcon)/AppIcon.png", side: 1024, background: 0x16181A, mark: svg("mark-dark"))
tile("\(appIcon)/AppIcon-dark.png", side: 1024, background: 0x000000, mark: svg("mark-dark"))
tile("\(appIcon)/AppIcon-tinted.png", side: 1024, background: 0x000000, mark: tinted)
tile("\(brand)/png/avatar-1024.png", side: 1024, background: 0x16181A, mark: svg("mark-dark"))

for (name, master, background) in [
    ("lockup-light", "lockup", UInt32(0xE9EBE8)),
    ("lockup-dark", "lockup-dark", UInt32(0x121416))
] {
    render("\(brand)/png/\(name)-1320.png", width: 1320, height: 408, background: background) { bounds in
        svg(master).draw(in: centered(CGSize(width: 1056, height: 198.4), in: bounds))
    }
}

// The social preview carries the lockup only. Any sentence belongs to the page that shares it.
render("\(brand)/png/social-1200x630.png", width: 1200, height: 630, background: 0x121416) { bounds in
    svg("lockup-dark").draw(in: centered(CGSize(width: 880, height: 165.33), in: bounds))
}
print("Exports written")
