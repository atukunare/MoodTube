# MoodTube — Development Guide

Developer reference for architecture, design system, release, and agent workflows.

## Agent entry

Canonical docs for this repo:

| Document | Purpose |
|----------|---------|
| [README.md](../README.md) | Overview, quick start, screenshots |
| [CHANGELOG.md](../CHANGELOG.md) | Release history |
| [CONTRIBUTING.md](../CONTRIBUTING.md) | Contribution guide |
| [docs/PRIVACY.md](PRIVACY.md) | Privacy policy (en/ko/zh) |
| [docs/ADS_GUIDE.md](ADS_GUIDE.md) | AdMob integration |

Scope: search and edit within this project folder unless an external path is explicitly required.

## 핵심 방향

- YouTube 오디오를 추출하지 않습니다.
- YouTube 영상을 다운로드하거나 캐시하지 않습니다.
- 모든 재생은 공식 **YouTube 임베드 플레이어**로만 이루어집니다.
- 공식 플레이어/컨트롤 위를 덮지 않습니다.
- 백그라운드 재생은 포함하지 않습니다.
- API 키가 없으면 mock 데이터로 동작합니다.
- UI는 **영어·한국어·중국어(간체)** 3개 언어를 지원합니다.

## 다국어 / i18n

- 3개 언어 현지화는 `AppText`에 모여 있습니다. 단순 문자열은 `_pick(ko, en, zh)`를 쓰고, 표 형태(`moodName`, `moodDescription`, `category`, `tag`)는 `ko`/`en`/`zh` 맵을 각각 가집니다.
- 로케일 연결: `supportedLocales` = en/ko/zh, `effectiveLanguageCode()`는 `auto`→기기→en 순으로 매핑.
- 중국어 렌더링은 시스템 CJK 폰트를 사용합니다 (`PingFang SC` / `Noto Sans SC` / `Noto Sans CJK SC`).

## 테마 (라이트 / 다크)

- 설정: **시스템 / 라이트 / 다크** (`MoodTubeState.themeMode`).
- `DesignTokens`는 밝기-반응형. 새 표면색은 토큰만 사용 (`panel`/`sheet`/`ink`/`muted`/`cardBorder`).

## 접근성 및 햅틱

- 다이얼: `HapticFeedback.selectionClick()`, 북마크: `lightImpact()`, 재생: `mediumImpact()`.
- 아이콘 전용 컨트롤에 `Semantics` 라벨. 터치 타깃 48dp.

## 릴리즈 & 서명

- `applicationId` = `com.moodtube.app`
- 릴리즈 서명: `android/key.properties` → `upload-keystore.jks` (both gitignored). Template: `android/key.properties.example`.
- R8/난독화 활성화. AAB에 `debugSymbolLevel = "SYMBOL_TABLE"`.

## UI 디자인 — "Mood Spectrum"

2026-06-12 전면 리뉴얼. **명시적 요청 없이 이전 파스텔 오로라/뉴모피즘으로 되돌리지 마세요.**

- **시그니처 4색 그라데이션** `DesignTokens.spectrum`: `#5b8cff` → `#8b5cf6` → `#ff5e8a` → `#ff8a56`
- 표면: 다크 `#0a0a10` / `#15151e`, 라이트 `#f6f5f2` / 흰색 패널
- 핵심 위젯: `AuroraMoodDial`, `SmartPickCard`, `PremiumHeader`, `SoftBackdrop`, `QuickMoodChip`
- 모듈 구조: 16개 독립 모듈 (`lib/state`, `lib/services`, `lib/screens`, `lib/widgets`, …)

## 검색, 스마트 픽, 재생

- API 모드: YouTube Data API + 긴 플레이리스트 의도. 실패 시 `mockCatalog` 폴백.
- 스마트 픽: 조회수 높은 긴 플레이리스트 우선 + Scapetune 스포트라이트 1개.
- Scapetune: `https://www.youtube.com/@my_scapetune`
- 일일 API 상한: `kDailyApiSearchLimit` = 12 (기기당). Explore 검색은 **검색 1회**만 API를 쓰고 스포트라이트는 오프라인 카탈로그를 사용합니다.
- 재생 오류 시: 큐가 있으면 블랙리스트 후 다음 트랙 자동 스킵(홈/탐색/보관함/Scapetune 배너).

## YouTube API 키

소스에 포함하지 않습니다. 빌드 시 주입:

```bash
cp dart_defines.json.example dart_defines.json
flutter build appbundle --release --dart-define-from-file=dart_defines.json
```

## 광고 (AdMob)

- `google_mobile_ads` + **UMP(GDPR) 동의** (`lib/ads/ads_real.dart`)
- 네이티브 슬롯: 홈 스마트 픽 3번째 뒤(`smartPickAd`), 검색 결과 4번째 뒤(`resultsListAd`)
- 앱 ID: `ca-app-pub-9993388177095923~4694181215` (AndroidManifest)
- 상세: [ADS_GUIDE.md](ADS_GUIDE.md)

## 개인정보처리방침

- [PRIVACY.md](PRIVACY.md) + [privacy.html](privacy.html)
- 호스팅 URL: `https://legitstudio.cc/moodtube/privacy`

## 웹 미리보기

```bash
./preview.sh
# http://localhost:5198/preview.html
```

임베드 YouTube 플레이어는 웹 미지원 — 레이아웃 확인용.

## 테스트

```bash
flutter analyze
flutter test
```

카탈로그 검증: `tools/check_catalog.sh`
