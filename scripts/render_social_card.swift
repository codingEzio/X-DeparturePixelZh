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

func draw(_ text: String, size: CGFloat, at point: CGPoint,
          color: NSColor = foreground) {
  let value = NSAttributedString(string: text, attributes: [
    kCTFontAttributeName as NSAttributedString.Key: font(size),
    kCTForegroundColorAttributeName as NSAttributedString.Key: color.cgColor,
  ])
  context.textPosition = point
  CTLineDraw(CTLineCreateWithAttributedString(value), context)
}

func drawSystem(_ text: String, size: CGFloat, weight: NSFont.Weight,
                at point: CGPoint, color: NSColor) {
  let value = NSAttributedString(string: text, attributes: [
    .font: NSFont.monospacedSystemFont(ofSize: size, weight: weight),
    .foregroundColor: color,
  ])
  context.textPosition = point
  CTLineDraw(CTLineCreateWithAttributedString(value), context)
}

let cell: CGFloat = 108
let gridOrigin = CGPoint(x: 1086, y: 348)
for column in 0...4 {
  let x = gridOrigin.x + CGFloat(column) * cell
  context.setStrokeColor(grid.cgColor)
  context.setLineWidth(column == 0 || column == 4 ? 2 : 1)
  context.move(to: CGPoint(x: x, y: gridOrigin.y))
  context.addLine(to: CGPoint(x: x, y: gridOrigin.y + 2 * cell))
  context.strokePath()
}
for row in 0...2 {
  let y = gridOrigin.y + CGFloat(row) * cell
  context.setStrokeColor(grid.cgColor)
  context.setLineWidth(row == 0 || row == 2 ? 2 : 1)
  context.move(to: CGPoint(x: gridOrigin.x, y: y))
  context.addLine(to: CGPoint(x: gridOrigin.x + 4 * cell, y: y))
  context.strokePath()
}

drawSystem("PROJECT · PIXEL MONO", size: 24, weight: .semibold,
  at: CGPoint(x: 96, y: 782), color: muted)
draw("DeparturePixelZh", size: 80, at: CGPoint(x: 91, y: 655))
draw("Compact", size: 126, at: CGPoint(x: 86, y: 495), color: accent)
draw("Hello，像素。", size: 62, at: CGPoint(x: 94, y: 352))
drawSystem("English 1 cell · 中文 2 cells", size: 30, weight: .medium,
  at: CGPoint(x: 98, y: 248), color: foreground)
drawSystem("650 / 1300 units · 7.14% tighter", size: 24, weight: .regular,
  at: CGPoint(x: 98, y: 181), color: muted)

draw("A", size: 72, at: CGPoint(x: gridOrigin.x + 31, y: gridOrigin.y + 38))
draw("B", size: 72, at: CGPoint(x: gridOrigin.x + cell + 31, y: gridOrigin.y + 38))
draw("中", size: 72, at: CGPoint(x: gridOrigin.x + 2 * cell + 40, y: gridOrigin.y + 38))
drawSystem("1", size: 20, weight: .medium,
  at: CGPoint(x: gridOrigin.x + 47, y: gridOrigin.y - 42), color: muted)
drawSystem("1", size: 20, weight: .medium,
  at: CGPoint(x: gridOrigin.x + cell + 47, y: gridOrigin.y - 42), color: muted)
drawSystem("2 cells", size: 20, weight: .medium,
  at: CGPoint(x: gridOrigin.x + 2 * cell + 63, y: gridOrigin.y - 42), color: muted)

guard let image = context.makeImage(),
      let png = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:]) else {
  fputs("cannot encode PNG\n", stderr)
  exit(1)
}
try FileManager.default.createDirectory(
  at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
try png.write(to: outputURL)
print("rendered \(outputURL.path) with \(CTFontCopyPostScriptName(compactFace) as String)")
