import SwiftUI
import AppKit

/// The window's backdrop: a night sky like the file-select screen's, dark at the top and deep blue below, with soft clouds lit from underneath.
/// The clouds are drawn here (fractal value noise, several octaves), not taken from a photo, so the app carries no image it may not share.
enum Sky {
    static let image: NSImage = render(width: 960, height: 600)

    private static func hash(_ x: Int, _ y: Int, _ seed: Int) -> Double {
        var h = UInt64(bitPattern: Int64(x &* 374761393 &+ y &* 668265263 &+ seed &* 2147483647))
        h = (h ^ (h >> 13)) &* 1274126177; h ^= h >> 16
        return Double(h & 0xffff) / 65535.0
    }
    private static func noise(_ x: Double, _ y: Double, _ seed: Int) -> Double {
        let xi = Int(floor(x)), yi = Int(floor(y)), xf = x - floor(x), yf = y - floor(y)
        let u = xf * xf * (3 - 2 * xf), v = yf * yf * (3 - 2 * yf)
        let a = hash(xi, yi, seed), b = hash(xi + 1, yi, seed), c = hash(xi, yi + 1, seed), d = hash(xi + 1, yi + 1, seed)
        return (a + (b - a) * u) + ((c + (d - c) * u) - (a + (b - a) * u)) * v
    }
    /// fBm: sum of octaves, stretched sideways so the clouds lie in long banks
    private static func clouds(_ x: Double, _ y: Double) -> Double {
        var f = 0.0, amp = 0.55, fx = x * 2.6, fy = y * 6.0
        for o in 0..<7 { f += amp * noise(fx, fy, 17 + o * 31); fx *= 2.03; fy *= 2.03; amp *= 0.5 }
        return f
    }
    private static func render(width w: Int, height h: Int) -> NSImage {
        var px = [UInt8](repeating: 255, count: w * h * 4)
        for j in 0..<h {
            let t = Double(j) / Double(h - 1)   // 0 top, 1 bottom
            // the ground: near black at the top, through navy, to a bright blue at the bottom
            let base = (r: 0.0 + 0.07 * pow(t, 1.6), g: 0.004 + 0.18 * pow(t, 1.5), b: 0.03 + 0.66 * pow(t, 1.3))
            for i in 0..<w {
                let s = Double(i) / Double(w - 1)
                let n = clouds(s * 1.6, t)
                // cloud cover grows toward the lower half; a soft band of light low and to the left, as in the reference
                let cover = max(0, min(1, (n - 0.50 + 0.22 * t) * 2.6)) * (0.25 + 0.75 * t)
                let glow = exp(-pow((t - 0.72) / 0.22, 2)) * exp(-pow((s - 0.38) / 0.45, 2)) * 0.35
                let lit = (r: 0.42 + 0.30 * t, g: 0.55 + 0.25 * t, b: 0.95)   // cloud colour: cool blue-white, brighter lower down
                let a = min(1, cover * 0.85)
                let r = base.r * (1 - a) + lit.r * a * (0.35 + 0.65 * t) + glow * 0.25
                let g = base.g * (1 - a) + lit.g * a * (0.35 + 0.65 * t) + glow * 0.35
                let b = base.b * (1 - a) + lit.b * a * (0.40 + 0.60 * t) + glow * 0.55
                let k = (j * w + i) * 4
                px[k] = UInt8(max(0, min(255, r * 255))); px[k + 1] = UInt8(max(0, min(255, g * 255))); px[k + 2] = UInt8(max(0, min(255, b * 255)))
            }
        }
        let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: w, pixelsHigh: h, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                   colorSpaceName: .deviceRGB, bytesPerRow: w * 4, bitsPerPixel: 32)!
        px.withUnsafeBytes { memcpy(rep.bitmapData!, $0.baseAddress!, w * h * 4) }
        let im = NSImage(size: NSSize(width: w, height: h)); im.addRepresentation(rep); return im
    }
}

struct SkyBackground: View {
    var body: some View {
        Image(nsImage: Sky.image).resizable().interpolation(.high).scaledToFill()
            .overlay(LinearGradient(colors: [.black.opacity(0.35), .clear], startPoint: .top, endPoint: .center))
            .accessibilityHidden(true)
    }
}
