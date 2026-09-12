import AppKit
import CoreText

guard CommandLine.arguments.count == 2 else {
  fputs("usage: swift scripts/render_social_card.swift OUTPUT.png\n", stderr)
  exit(64)
}

let outputURL = URL(fileURLWithPath: CommandLine.arguments[1])
let fontURL = URL(fileURLWithPath: #filePath)
  .deletingLastPathComponent()
  .deletingLastPathComponent()
  .appendingPathComponent("Build/DeparturePixelZhCompact-Regular.ttf")

guard let provider = CGDataProvider(url: fontURL as CFURL),
      let cgFont = CGFont(provider) else {
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

let background = NSColor(calibratedRed: 0.015, green: 0.085, blue: 0.055, alpha: 1)
let foreground = NSColor(calibratedRed: 0.82, green: 1.0, blue: 0.88, alpha: 1)
let accent = NSColor(calibratedRed: 0.25, green: 0.94, blue: 0.56, alpha: 1)
let muted = NSColor(calibratedRed: 0.47, green: 0.72, blue: 0.57, alpha: 1)
let grid = NSColor(calibratedRed: 0.17, green: 0.48, blue: 0.31, alpha: 0.38)
context.setFillColor(background.cgColor)
context.fill(CGRect(x: 0, y: 0, width: width, height: height))

let compactFace = CTFontCreateWithGraphicsFont(cgFont, 1, nil, nil)

func font(_ size: CGFloat) -> CTFont {
  CTFontCreateCopyWithAttributes(compactFace, size, nil, nil)
}

func line(_ text: String, size: CGFloat, color: NSColor = foreground) -> CTLine {
  let value = NSAttributedString(string: text, attributes: [
    kCTFontAttributeName as NSAttributedString.Key: font(size),
    kCTForegroundColorAttributeName as NSAttributedString.Key: color.cgColor,
  ])
  return CTLineCreateWithAttributedString(value)
}

func systemLine(_ text: String, size: CGFloat, weight: NSFont.Weight,
                color: NSColor) -> CTLine {
  let value = NSAttributedString(string: text, attributes: [
    .font: NSFont.monospacedSystemFont(ofSize: size, weight: weight),
    .foregroundColor: color,
  ])
  return CTLineCreateWithAttributedString(value)
}

func drawCentered(_ line: CTLine, y: CGFloat, safe: Bool = true) {
  let lineWidth = CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
  let x = (CGFloat(width) - lineWidth) / 2
  if safe && (x < 220 || x + lineWidth > 1380) {
    fputs("centered line exceeds the social-card safe area\n", stderr)
    exit(1)
  }
  context.textPosition = CGPoint(x: x, y: y)
  CTLineDraw(line, context)
}

// The four-cell example stays in the center-safe area used by blog and social crops.
let cell: CGFloat = 102
let gridOrigin = CGPoint(x: 596, y: 70)
for column in 0...4 {
  let x = gridOrigin.x + CGFloat(column) * cell
  context.setStrokeColor(grid.cgColor)
  context.setLineWidth(column == 0 || column == 4 ? 2 : 1)
  context.move(to: CGPoint(x: x, y: gridOrigin.y))
  context.addLine(to: CGPoint(x: x, y: gridOrigin.y + cell))
  context.strokePath()
}
for row in 0...1 {
  let y = gridOrigin.y + CGFloat(row) * cell
  context.setStrokeColor(grid.cgColor)
  context.setLineWidth(row == 0 || row == 1 ? 2 : 1)
  context.move(to: CGPoint(x: gridOrigin.x, y: y))
  context.addLine(to: CGPoint(x: gridOrigin.x + 4 * cell, y: y))
  context.strokePath()
}

drawCentered(systemLine("PROJECT · PIXEL MONO", size: 22, weight: .semibold, color: muted), y: 790)
drawCentered(line("DeparturePixelZh", size: 82), y: 650)
drawCentered(line("Compact", size: 136, color: accent), y: 475)
drawCentered(line("Hello，像素。", size: 64), y: 340)
drawCentered(systemLine("ENGLISH 1 CELL · 中文 2 CELLS", size: 28, weight: .medium, color: foreground), y: 248)

func drawInCell(_ text: String, column: Int, columns: Int = 1) {
  let glyph = line(text, size: 66)
  let glyphWidth = CGFloat(CTLineGetTypographicBounds(glyph, nil, nil, nil))
  let span = CGFloat(columns) * cell
  context.textPosition = CGPoint(
    x: gridOrigin.x + CGFloat(column) * cell + (span - glyphWidth) / 2,
    y: gridOrigin.y + 22)
  CTLineDraw(glyph, context)
}

drawInCell("A", column: 0)
drawInCell("B", column: 1)
drawInCell("中", column: 2, columns: 2)

guard let image = context.makeImage(),
      let png = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:]) else {
  fputs("cannot encode PNG\n", stderr)
  exit(1)
}
try FileManager.default.createDirectory(
  at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
try png.write(to: outputURL)
print("rendered \(outputURL.path) with \(CTFontCopyPostScriptName(compactFace) as String)")
