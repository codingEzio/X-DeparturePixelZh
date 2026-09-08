# DeparturePixelZh

[English](README.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md)

English and Chinese pixel glyphs in one monospaced font. Latin characters use one cell; full-width Chinese characters use two. Developer icons are included. Color emoji use the system font.

The family combines [Departure Mono](https://github.com/rektdeckard/departure-mono), [Cubic 11](https://github.com/ACh-K/Cubic-11), and Nerd Fonts Symbols Mono.

## Choose a font

| Family | PostScript name | Spacing |
| --- | --- | --- |
| DeparturePixelZh | `DeparturePixelZh-Regular` | Standard |
| DeparturePixelZh Compact | `DeparturePixelZhCompact-Regular` | About 7.14% tighter |

Both are Regular, upright fonts with the same line height. Compact has fitted glyphs and its own spacing; no application letter-spacing adjustment is needed.

## Use

Install the TTF for desktop use. Use WOFF2 on the web. Packages include fonts, checksums, source records, and license notices. Keep `OFL.txt`, `NOTICE.md`, and `licenses/` when redistributing or bundling the fonts.

Apple applications that register a bundled font should use its exact PostScript name. For web use, load the WOFF2 file without a `local()` source and keep a system fallback.

## Rebuild

Requires [uv](https://docs.astral.sh/uv/) and a sibling DeparturePixelZhBuilder checkout. Use the builder revision recorded in [builder-version](builder-version); release checks require that exact clean checkout.

```sh
cd ../DeparturePixelZhBuilder
uv run departurepixelzh-builder build --recipe ../DeparturePixelZh/recipe.json --output ../DeparturePixelZh/Build
uv run departurepixelzh-builder check --recipe ../DeparturePixelZh/recipe.json --output ../DeparturePixelZh/Build
```

On macOS, run `swift scripts/check_native.swift Build` from this repository for native font checks. Use `--development` only for local builder development; it bypasses the revision pin and cannot produce a release candidate.

[recipe.json](recipe.json) pins source URLs and SHA-256 hashes. Builds do not use installed fonts as input. [consumer-fixture/](consumer-fixture/) shows how to copy verified fonts, notices, and source records into a consumer project.

## Coverage and limits

Departure Mono has priority for overlapping text characters; Cubic 11 fills remaining Chinese coverage. Nerd Fonts Symbols Mono supplies private-use icons. Generated coverage files identify the source of each included code point.

Only Regular upright faces are provided. Unsupported characters and color emoji need fallback fonts. Appearance depends on font size, display scaling, and the application; the project does not claim verified rendering on every platform.

## License

Fonts use the [SIL Open Font License 1.1](OFL.txt). See [NOTICE.md](NOTICE.md) and [licenses/](licenses/) for attribution, modifications, reserved names, and component terms. DeparturePixelZh is an independent derived name. Source authors and trademark owners do not endorse it.
