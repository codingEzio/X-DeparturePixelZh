# DeparturePixelZh

[English](README.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md)

一款等宽字体，同时装下英文像素字和中文像素字。英文占一格，中文全角字占两格，也包含开发者图标。彩色 emoji 使用系统字体。

[下载 DeparturePixelZh 0.1.0（ZIP）](https://github.com/codingEzio/X-DeparturePixelZh/releases/download/v0.1.0/DeparturePixelZh-0.1.0.zip) · [所有版本](https://github.com/codingEzio/X-DeparturePixelZh/releases)

![DeparturePixelZh：一款字体，中英像素等宽](assets/departurepixelzh-social-card.png)

字体组合自 [Departure Mono](https://github.com/rektdeckard/departure-mono)、[Cubic 11](https://github.com/ACh-K/Cubic-11) 和 Nerd Fonts Symbols Mono。

## 选择版本

| 字体 | PostScript 名称 | 间距 |
| --- | --- | --- |
| DeparturePixelZh | `DeparturePixelZh-Regular` | 标准 |
| DeparturePixelZh Compact | `DeparturePixelZhCompact-Regular` | 收紧约 7.14% |

两款均为 Regular 正体，行高相同。Compact 已适配字形和间距，无需另调应用字距。

## 使用

桌面安装 TTF，网页使用 WOFF2。字体包包含字体、校验和、来源记录和许可材料。再分发或随应用捆绑时，请保留 `OFL.txt`、`NOTICE.md` 和 `licenses/`。

Apple 应用注册内置字体时，应使用准确的 PostScript 名称。网页应直接加载 WOFF2，不使用 `local()` 来源，并保留系统备用字体。

## 重新构建

需要 [uv](https://docs.astral.sh/uv/) 和同级目录中的 X-DeparturePixelZhBuilder。构建器必须切换到 [builder-version](builder-version) 记录的版本；发布检查要求该版本的工作区没有改动。

```sh
cd ../X-DeparturePixelZhBuilder
uv run departurepixelzh-builder build --recipe ../X-DeparturePixelZh/recipe.json --output ../X-DeparturePixelZh/Build
uv run departurepixelzh-builder check --recipe ../X-DeparturePixelZh/recipe.json --output ../X-DeparturePixelZh/Build
```

macOS 可在本仓库运行 `swift scripts/check_native.swift Build`，检查原生字体表现。`--development` 仅用于本地构建器开发；它跳过版本锁定，不能生成发布候选。

[recipe.json](recipe.json) 固定来源 URL 和 SHA-256。构建器从这些 URL 下载输入文件，或复用缓存，并按固定的 SHA-256 校验；不会读取 macOS 已安装字体作为构建输入。[consumer-fixture/](consumer-fixture/) 演示如何把验证过的字体、许可和来源记录一并复制到使用方项目。

## 覆盖与限制

重复的文字字符优先采用 Departure Mono，Cubic 11 补充其余中文覆盖，Nerd Fonts Symbols Mono 提供私用区图标。生成的覆盖文件记录每个收录码位的来源。

目前只提供 Regular 正体。未收录字符和彩色 emoji 需要备用字体。效果取决于字号、屏幕缩放和应用，项目不声称已验证所有平台。

## 可选：对比原版字体

在装有 Homebrew 的 macOS 上，可以安装原版字体做视觉对比。这不是构建前提，安装或使用 DeparturePixelZh 也不需要这一步。

```sh
brew install --cask font-departure-mono font-cubic-11
```

## 许可

字体使用 [SIL Open Font License 1.1](OFL.txt)。署名、修改、保留名称与组件条款见 [NOTICE.md](NOTICE.md) 和 [licenses/](licenses/)。DeparturePixelZh 是独立的衍生名称，不代表原作者或商标权利人为它背书。
