import AppKit
import CoreText

guard CommandLine.arguments.count == 3 else {
  fputs("usage: swift scripts/render_social_card.swift BACKGROUND.png OUTPUT.png\n", stderr)
  exit(64)
}

let backgroundURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])
let fontURL = URL(fileURLWithPath: #filePath)
  .deletingLastPathComponent()
  .deletingLastPathComponent()
  .appendingPathComponent("Build/DeparturePixelZh-Regular.ttf")

guard let background = NSImage(contentsOf: backgroundURL)?.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
  fputs("cannot load background: \(backgroundURL.path)\n", stderr)
  exit(1)
}
guard let provider = CGDataProvider(url: fontURL as CFURL), let cgFont = CGFont(provider) else {
  fputs("cannot load font: \(fontURL.path)\n", stderr)
  exit(1)
}

let width = 1600
let height = 900
guard let context = CGContext(
  data: nil,
  width: width,
  height: height,
  bitsPerComponent: 8,
  bytesPerRow: 0,
  space: CGColorSpaceCreateDeviceRGB(),
  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
  fputs("cannot create image context\n", stderr)
  exit(1)
}

context.interpolationQuality = .high
context.draw(background, in: CGRect(x: 0, y: 0, width: width, height: height))

let overlay = CGGradient(
  colorsSpace: CGColorSpaceCreateDeviceRGB(),
  colors: [
    NSColor(calibratedRed: 0.0, green: 0.08, blue: 0.04, alpha: 0.90).cgColor,
    NSColor(calibratedRed: 0.0, green: 0.08, blue: 0.04, alpha: 0.42).cgColor,
    NSColor(calibratedRed: 0.0, green: 0.08, blue: 0.04, alpha: 0.0).cgColor,
  ] as CFArray,
  locations: [0.0, 0.52, 1.0]
)!
context.drawLinearGradient(
  overlay,
  start: CGPoint(x: 0, y: height / 2),
  end: CGPoint(x: width, y: height / 2),
  options: []
)

let face = CTFontCreateWithGraphicsFont(cgFont, 1, nil, nil)
let foreground = NSColor(calibratedRed: 0.82, green: 1.0, blue: 0.88, alpha: 1.0)
let muted = NSColor(calibratedRed: 0.50, green: 0.82, blue: 0.62, alpha: 1.0)

func draw(_ text: String, size: CGFloat, at point: CGPoint, color: NSColor = foreground) {
  let font = CTFontCreateCopyWithAttributes(face, size, nil, nil)
  let value = NSAttributedString(string: text, attributes: [
    kCTFontAttributeName as NSAttributedString.Key: font,
    kCTForegroundColorAttributeName as NSAttributedString.Key: color.cgColor,
  ])
  context.textPosition = point
  CTLineDraw(CTLineCreateWithAttributedString(value), context)
}

draw("DeparturePixelZh", size: 86, at: CGPoint(x: 96, y: 694))
draw("ENGLISH × 中文", size: 58, at: CGPoint(x: 100, y: 560))
draw("A B C   中 文", size: 46, at: CGPoint(x: 100, y: 448))
draw("1 cell · 2 cells", size: 29, at: CGPoint(x: 103, y: 365), color: muted)

guard let image = context.makeImage(), let png = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:]) else {
  fputs("cannot encode PNG\n", stderr)
  exit(1)
}
try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
try png.write(to: outputURL)
print("rendered \(outputURL.path) with \(CTFontCopyPostScriptName(face) as String)")
