# DeparturePixelZh

[English](README.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md)

英字と中国語のピクセル字形を、一つの等幅フォントにまとめました。英字は1セル、中国語の全角文字は2セルを使います。開発者向けアイコンも含みます。カラー絵文字はシステムフォントで表示します。

[Departure Mono](https://github.com/rektdeckard/departure-mono)、[Cubic 11](https://github.com/ACh-K/Cubic-11)、Nerd Fonts Symbols Monoを組み合わせたフォントです。

## フォントを選ぶ

| ファミリー | PostScript名 | 文字間隔 |
| --- | --- | --- |
| DeparturePixelZh | `DeparturePixelZh-Regular` | 標準 |
| DeparturePixelZh Compact | `DeparturePixelZhCompact-Regular` | 約7.14%狭い |

どちらもRegularの正体で、行の高さは同じです。Compactは字形と間隔を調整済みなので、アプリ側で字間を変更する必要はありません。

## 使い方

デスクトップにはTTFをインストールし、WebではWOFF2を使います。パッケージにはフォント、チェックサム、出典記録、ライセンス文書が含まれます。再配布やアプリへの同梱時は、`OFL.txt`、`NOTICE.md`、`licenses/`を保持してください。

Appleアプリで同梱フォントを登録する場合は、正確なPostScript名を指定します。Webでは`local()`を使わずにWOFF2を読み込み、システムの代替フォントも指定してください。

## 再ビルド

[uv](https://docs.astral.sh/uv/)と、同じ親ディレクトリにあるDeparturePixelZhBuilderが必要です。[builder-version](builder-version)に記録されたリビジョンを使ってください。リリース検証には、そのリビジョンの未変更の作業ツリーが必要です。

```sh
cd ../DeparturePixelZhBuilder
uv run departurepixelzh-builder build --recipe ../DeparturePixelZh/recipe.json --output ../DeparturePixelZh/Build
uv run departurepixelzh-builder check --recipe ../DeparturePixelZh/recipe.json --output ../DeparturePixelZh/Build
```

macOSでは、このリポジトリから`swift scripts/check_native.swift Build`を実行してネイティブ描画を検証できます。`--development`はビルダーのローカル開発専用です。リビジョンの固定を省略するため、リリース候補は生成できません。

[recipe.json](recipe.json)は出典URLとSHA-256を固定します。インストール済みフォントは入力に使いません。[consumer-fixture/](consumer-fixture/)は、検証済みフォント、ライセンス文書、出典記録を利用側プロジェクトへまとめてコピーする例です。

## 収録範囲と制限

重複する文字はDeparture Monoを優先し、Cubic 11が残りの中国語文字を補います。Nerd Fonts Symbols Monoが私用領域のアイコンを提供します。生成された収録範囲ファイルで、各コードポイントの出典を確認できます。

Regularの正体のみです。未収録文字とカラー絵文字には代替フォントが必要です。見え方は文字サイズ、画面の拡大率、アプリに依存します。すべてのプラットフォームでの描画を検証したわけではありません。

## ライセンス

フォントは[SIL Open Font License 1.1](OFL.txt)で配布します。帰属表示、変更点、予約名、各コンポーネントの条件は[NOTICE.md](NOTICE.md)と[licenses/](licenses/)を参照してください。DeparturePixelZhは独立した派生名であり、原作者や商標権者の推奨を意味しません。
