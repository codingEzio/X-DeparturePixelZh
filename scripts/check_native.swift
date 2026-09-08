import AppKit
import CoreText

let root = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "Build")
let installed = CommandLine.arguments.contains("--installed")
let families = [
  ("DeparturePixelZh", "DeparturePixelZh", 28.0),
  ("DeparturePixelZh Compact", "DeparturePixelZhCompact", 26.0),
]
let samples = [
  "Hello，字体合奏。MWil 0123 ┌───┐",
  "中 English 文，Café e\u{0301} q\u{0301} x\u{030C} \u{e0b0} \u{f07b} \u{f09b} \u{f0219}",
  "😀 ❤️ 👍🏽 👨‍👩‍👧‍👦 🇹🇼",
]
var failures = [String]()
var checks = [[String: Any]]()

for (family, postscript, expectedWidth) in families {
  let file = root.appendingPathComponent("\(postscript)-Regular.ttf")
  if !installed {
    var error: Unmanaged<CFError>?
    if !CTFontManagerRegisterFontsForURL(file as CFURL, .process, &error) {
      failures.append("registration \(postscript): \(String(describing: error))")
      continue
    }
  }
  let font = CTFontCreateWithName("\(postscript)-Regular" as CFString, 22, nil)
  if CTFontCopyFamilyName(font) as String != family { failures.append("family \(postscript)") }
  if CTFontCopyPostScriptName(font) as String != "\(postscript)-Regular" { failures.append("PostScript \(postscript)") }
  if installed {
    let expected = FileManager.default.homeDirectoryForCurrentUser
      .appendingPathComponent("Library/Fonts/\(postscript)-Regular.ttf")
      .resolvingSymlinksInPath()
    let actual = (CTFontCopyAttribute(font, kCTFontURLAttribute) as? URL)?.resolvingSymlinksInPath()
    if actual != expected { failures.append("installed provider \(postscript)") }
  }
  for text in ["AA", "中"] {
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: [.font: font]))
    if abs(CTLineGetTypographicBounds(line, nil, nil, nil) - expectedWidth) > 0.01 {
      failures.append("advance \(postscript) \(text)")
    }
  }
  for (index, text) in samples.enumerated() {
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: [.font: font]))
    let providers = (CTLineGetGlyphRuns(line) as! [CTRun]).map { run -> String in
      CTFontCopyPostScriptName((CTRunGetAttributes(run) as NSDictionary)[kCTFontAttributeName] as! CTFont) as String
    }
    if index < 2 && providers.contains(where: { $0 != "\(postscript)-Regular" }) {
      failures.append("unexpected fallback \(postscript) sample \(index)")
    }
    if index == 2 && !providers.contains("AppleColorEmoji") { failures.append("emoji fallback \(postscript)") }
    checks.append(["family": family, "sample": index, "providers": providers])
  }
}

let width = 1600, height = 760
let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
  space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
context.setFillColor(CGColor(red: 0.96, green: 0.95, blue: 0.91, alpha: 1))
context.fill(CGRect(x: 0, y: 0, width: width, height: height))
for (index, (family, postscript, _)) in families.enumerated() {
  var y: CGFloat = 690
  let x: CGFloat = index == 0 ? 60 : 830
  let title = NSAttributedString(string: family, attributes: [.font: NSFont.systemFont(ofSize: 22), .foregroundColor: NSColor.darkGray])
  context.textPosition = CGPoint(x: x, y: y)
  CTLineDraw(CTLineCreateWithAttributedString(title), context)
  y -= 55
  for size: CGFloat in [16, 22, 28] {
    let font = CTFontCreateWithName("\(postscript)-Regular" as CFString, size, nil)
    for text in samples {
      context.textPosition = CGPoint(x: x, y: y)
      CTLineDraw(CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: NSColor.black])), context)
      y -= 47
    }
    y -= 28
  }
}
let image = NSBitmapImageRep(cgImage: context.makeImage()!)
try image.representation(using: .png, properties: [:])!.write(to: root.appendingPathComponent("native-specimen.png"))
let data = try JSONSerialization.data(withJSONObject: ["installed": installed, "checks": checks, "failures": failures], options: [.prettyPrinted, .sortedKeys])
try data.write(to: root.appendingPathComponent("native-report.json"))
print(String(data: data, encoding: .utf8)!)
if !failures.isEmpty { exit(1) }
