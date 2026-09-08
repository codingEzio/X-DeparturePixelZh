# DeparturePixelZh

DeparturePixelZh is a pixel-inspired, monospaced Chinese/Latin font family assembled from [Departure Mono](https://github.com/rektdeckard/departure-mono), [Cubic 11](https://github.com/ACh-K/Cubic-11), and Nerd Fonts Symbols Mono. It is a self-contained text-and-icon font; emoji remain a system fallback.

| Family | PostScript name | Latin / full-width advance |
| --- | --- | --- |
| DeparturePixelZh | `DeparturePixelZh-Regular` | 700 / 1,400 units |
| DeparturePixelZh Compact | `DeparturePixelZhCompact-Regular` | 650 / 1,300 units |

Compact is 7.14% tighter. It is a separate font with fitted outlines and adjusted mark positioning, not an application letter-spacing setting. Both faces are Regular (400), upright, and use the same 1,100-unit em and 1,700-unit line box.

## Install

Release archives contain TTF files, WOFF2 files, `OFL.txt`, `NOTICE.md`, component notices, checksums, and public provenance. Install the TTF matching the desired family. Applications that redistribute a font must include the same notice material.

Use the exact PostScript name when an Apple application registers the bundled file. Web applications should use the WOFF2 asset without a `local()` source and should keep a normal system fallback for first paint.

## Rebuild

The recipe pins each upstream input by URL and SHA-256. A build never reads an installed font as a source.

```sh
cd ../DeparturePixelZhBuilder
uv run departurepixelzh-builder build --recipe ../DeparturePixelZh/recipe.json \
  --output ../DeparturePixelZh/Build
uv run departurepixelzh-builder check --recipe ../DeparturePixelZh/recipe.json \
  --output ../DeparturePixelZh/Build
cd ../DeparturePixelZh
swift scripts/check_native.swift Build
```

For an identity-only migration, `scripts/check_compatibility.py` compares coverage, every encoded glyph outline, and every advance width between a prior candidate and a rebuilt candidate. It accepts two explicit file paths so it does not encode a private predecessor or machine path.

This release pins the builder revision `b60103967e0a6722f57985aab4727c15ed2f7aec` in both `recipe.json` and `builder-version`. Release checks require that exact clean builder checkout. For local builder development only, pass `--development`; that bypasses the pin and cannot produce a release candidate.

The `consumer-fixture/` manifest demonstrates guarded adoption. It synchronizes selected binaries, notices, and public provenance together, keeps a receipt, detects drift, and never follows an unreviewed newer font.

## Coverage and limits

Departure Mono supplies overlapping Latin text; Cubic 11 supplies remaining Chinese coverage; Nerd Fonts Symbols Mono supplies private-use developer icons. Each generated `*_coverage.json` records the provider for every included code point. The builder normalizes coordinates, preserves one-cell/two-cell advances, fits Cubic 11 outlines at 95% optical scale, and verifies combining marks and box drawing.

Unsupported scripts and color emoji use platform fallback. The output does not claim bold, italic, variable-font, mobile, or cross-platform rendering support beyond the checked release artifacts.

## License and attribution

The font files are distributed under the [SIL Open Font License 1.1](OFL.txt). See [NOTICE.md](NOTICE.md) and [licenses/](licenses/) for source attribution, reserved names, modifications, and component notices. DeparturePixelZh is an independent derived name; `Cubic`, `俐方體`, `Pomicons`, and `Font Awesome` remain source-attribution names and are not presented as derived-family names.
