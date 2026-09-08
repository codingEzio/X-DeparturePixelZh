# DeparturePixelZh

[English](README.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md)

영문과 중국어 픽셀 글자를 하나의 고정폭 글꼴에 담았습니다. 영문은 한 칸, 중국어 전각 글자는 두 칸을 차지합니다. 개발자 아이콘도 포함합니다. 컬러 이모지는 시스템 글꼴을 사용합니다.

[Departure Mono](https://github.com/rektdeckard/departure-mono), [Cubic 11](https://github.com/ACh-K/Cubic-11), Nerd Fonts Symbols Mono를 조합한 글꼴입니다.

## 글꼴 선택

| 패밀리 | PostScript 이름 | 간격 |
| --- | --- | --- |
| DeparturePixelZh | `DeparturePixelZh-Regular` | 표준 |
| DeparturePixelZh Compact | `DeparturePixelZhCompact-Regular` | 약 7.14% 좁음 |

두 글꼴 모두 Regular 정체이며 줄 높이는 같습니다. Compact는 글자 모양과 간격이 조정되어 있어 앱에서 자간을 따로 바꿀 필요가 없습니다.

## 사용

데스크톱에는 TTF를 설치하고 웹에서는 WOFF2를 사용합니다. 패키지에는 글꼴, 체크섬, 출처 기록, 라이선스 문서가 포함됩니다. 재배포하거나 앱에 포함할 때는 `OFL.txt`, `NOTICE.md`, `licenses/`를 유지하세요.

Apple 앱에서 포함된 글꼴을 등록할 때는 정확한 PostScript 이름을 사용하세요. 웹에서는 `local()` 소스 없이 WOFF2 파일을 불러오고 시스템 대체 글꼴도 지정하세요.

## 다시 빌드하기

[uv](https://docs.astral.sh/uv/)와 같은 상위 디렉터리에 있는 DeparturePixelZhBuilder가 필요합니다. [builder-version](builder-version)에 기록된 리비전을 사용하세요. 릴리스 검사는 해당 리비전의 작업 트리가 수정되지 않은 상태여야 합니다.

```sh
cd ../DeparturePixelZhBuilder
uv run departurepixelzh-builder build --recipe ../DeparturePixelZh/recipe.json --output ../DeparturePixelZh/Build
uv run departurepixelzh-builder check --recipe ../DeparturePixelZh/recipe.json --output ../DeparturePixelZh/Build
```

macOS에서는 이 저장소에서 `swift scripts/check_native.swift Build`를 실행해 네이티브 글꼴을 검사할 수 있습니다. `--development`는 로컬 빌더 개발에만 사용하세요. 리비전 고정을 건너뛰므로 릴리스 후보를 만들 수 없습니다.

[recipe.json](recipe.json)은 소스 URL과 SHA-256을 고정합니다. 설치된 글꼴을 입력으로 사용하지 않습니다. [consumer-fixture/](consumer-fixture/)는 검증한 글꼴, 라이선스 문서, 출처 기록을 사용 프로젝트에 함께 복사하는 예제입니다.

## 지원 범위와 한계

겹치는 문자에는 Departure Mono를 우선 사용하고 Cubic 11이 나머지 중국어 문자를 보완합니다. Nerd Fonts Symbols Mono는 사용자 정의 영역의 아이콘을 제공합니다. 생성된 지원 범위 파일에서 각 코드 포인트의 출처를 확인할 수 있습니다.

Regular 정체만 제공합니다. 지원하지 않는 문자와 컬러 이모지는 대체 글꼴이 필요합니다. 화면 표시는 글자 크기, 화면 배율, 앱에 따라 달라집니다. 모든 플랫폼에서 렌더링을 검증한 것은 아닙니다.

## 라이선스

글꼴은 [SIL Open Font License 1.1](OFL.txt)로 배포합니다. 저작자 표시, 변경 사항, 예약 이름, 구성 요소 조건은 [NOTICE.md](NOTICE.md)와 [licenses/](licenses/)를 참고하세요. DeparturePixelZh는 독립적인 파생 이름이며 원저작자나 상표권자의 보증을 뜻하지 않습니다.
