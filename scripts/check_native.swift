import AppKit
import CoreText

let root = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "Build")
let installed = CommandLine.arguments.contains("--installed")
let families = [
  ("DeparturePixelZh", "DeparturePixelZh", 28.0),
  ("DeparturePixelZh Compact", "DeparturePixelZhCompact", 26.0),
]
let textSamples = [
  "Hello World! MWiIl1 O0 09:41 +12.50%",
  "繁體中文，像素同行。編輯器與終端機。",
  "简体中文，像素同行。编辑器与终端。",
  "，。！？「」『』（）、；：——… ┌───┐ │ A │",
  "\u{e0b0}  \u{f07b}  \u{f09b}  \u{f0219}",
]
let emojiSample = "😀 ❤️ 👍🏽 🇹🇼"
var failures = [String]()
var checks = [[String: Any]]()
var loadedFonts = [String: CTFont]()

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
  loadedFonts[postscript] = font
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
  for (index, text) in textSamples.enumerated() {
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: [.font: font]))
    let providers = (CTLineGetGlyphRuns(line) as! [CTRun]).map { run -> String in
      CTFontCopyPostScriptName((CTRunGetAttributes(run) as NSDictionary)[kCTFontAttributeName] as! CTFont) as String
    }
    if providers.contains(where: { $0 != "\(postscript)-Regular" }) {
      failures.append("unexpected fallback \(postscript) sample \(index)")
    }
    checks.append(["family": family, "sample": index, "providers": providers])
  }
  let emojiLine = CTLineCreateWithAttributedString(NSAttributedString(string: emojiSample, attributes: [.font: font]))
  let emojiProviders = (CTLineGetGlyphRuns(emojiLine) as! [CTRun]).map { run -> String in
    CTFontCopyPostScriptName((CTRunGetAttributes(run) as NSDictionary)[kCTFontAttributeName] as! CTFont) as String
  }
  if !emojiProviders.contains("AppleColorEmoji") { failures.append("emoji fallback \(postscript)") }
  checks.append(["family": family, "sample": "emoji", "providers": emojiProviders])
}

guard let compact = loadedFonts["DeparturePixelZhCompact"],
      let standard = loadedFonts["DeparturePixelZh"] else {
  fputs("could not load both font variants\n", stderr)
  exit(1)
}

let width = 1600, height = 1000
let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
  space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
let paper = NSColor(calibratedRed: 0.965, green: 0.949, blue: 0.902, alpha: 1)
let ink = NSColor(calibratedRed: 0.075, green: 0.11, blue: 0.10, alpha: 1)
let muted = NSColor(calibratedRed: 0.34, green: 0.39, blue: 0.36, alpha: 1)
let accent = NSColor(calibratedRed: 0.06, green: 0.40, blue: 0.22, alpha: 1)
let panel = NSColor(calibratedRed: 0.91, green: 0.90, blue: 0.85, alpha: 1)
context.setFillColor(paper.cgColor)
context.fill(CGRect(x: 0, y: 0, width: width, height: height))

func resized(_ base: CTFont, _ size: CGFloat) -> CTFont {
  CTFontCreateCopyWithAttributes(base, size, nil, nil)
}

func draw(_ text: String, font: CTFont, at point: CGPoint, color: NSColor = ink) {
  let value = NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
  context.textPosition = point
  CTLineDraw(CTLineCreateWithAttributedString(value), context)
}

func drawSystem(_ text: String, size: CGFloat, weight: NSFont.Weight,
                at point: CGPoint, color: NSColor = muted) {
  draw(text, font: NSFont.monospacedSystemFont(ofSize: size, weight: weight), at: point, color: color)
}

draw("DeparturePixelZh Compact", font: resized(compact, 54), at: CGPoint(x: 64, y: 891), color: accent)
drawSystem("A mixed-script pixel specimen · actual macOS rendering", size: 22, weight: .medium,
  at: CGPoint(x: 67, y: 836))

let rows: [(String, String)] = [
  ("LATIN + NUMBERS", textSamples[0]),
  ("TRADITIONAL", textSamples[1]),
  ("SIMPLIFIED", textSamples[2]),
  ("PUNCTUATION + BOX", textSamples[3]),
  ("NERD FONT SYMBOLS", textSamples[4]),
  ("SYSTEM EMOJI FALLBACK", emojiSample),
]
var y: CGFloat = 755
for (label, sample) in rows {
  drawSystem(label, size: 17, weight: .semibold, at: CGPoint(x: 66, y: y + 19), color: muted)
  draw(sample, font: resized(compact, label == "SYSTEM EMOJI FALLBACK" ? 38 : 36),
    at: CGPoint(x: 310, y: y), color: ink)
  y -= 79
}

context.setFillColor(panel.cgColor)
context.fill(CGRect(x: 48, y: 74, width: 1504, height: 222))
drawSystem("SAME TEXT · DIFFERENT ADVANCE", size: 15, weight: .semibold,
  at: CGPoint(x: 70, y: 252), color: muted)
drawSystem("STANDARD", size: 15, weight: .semibold, at: CGPoint(x: 70, y: 190), color: muted)
draw("AA中文  MWiIl1  ┌───┐", font: resized(standard, 34), at: CGPoint(x: 250, y: 180), color: ink)
drawSystem("700 / 1400", size: 17, weight: .medium, at: CGPoint(x: 1260, y: 184), color: muted)
drawSystem("COMPACT", size: 15, weight: .semibold, at: CGPoint(x: 70, y: 117), color: accent)
draw("AA中文  MWiIl1  ┌───┐", font: resized(compact, 34), at: CGPoint(x: 250, y: 107), color: ink)
drawSystem("650 / 1300 · 7.14% tighter", size: 17, weight: .medium,
  at: CGPoint(x: 1120, y: 111), color: accent)

guard let outputImage = context.makeImage(),
      let png = NSBitmapImageRep(cgImage: outputImage).representation(using: .png, properties: [:]) else {
  fputs("cannot encode native specimen\n", stderr)
  exit(1)
}
try png.write(to: root.appendingPathComponent("native-specimen.png"))
let data = try JSONSerialization.data(withJSONObject: [
  "installed": installed,
  "checks": checks,
  "failures": failures,
  "specimen": ["width": width, "height": height, "focus": "DeparturePixelZh Compact"],
], options: [.prettyPrinted, .sortedKeys])
try data.write(to: root.appendingPathComponent("native-report.json"))
print(String(data: data, encoding: .utf8)!)
if !failures.isEmpty { exit(1) }
