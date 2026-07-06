# MoodTube

## Agent Entry

이 저장소의 정본 문서는 `README.md`와 `CHANGELOG.md`입니다.

- 변경 이력/로드맵: `CHANGELOG.md`
- 개인정보처리방침: `docs/PRIVACY.md`
- AdMob 연동: `docs/ADS_GUIDE.md`
- 작업 범위: 기본적으로 이 프로젝트 폴더 안에서만 검색·수정합니다.

MoodTube는 기분(mood)별로 YouTube의 긴 음악 플레이리스트를 찾아주는 Flutter Android 앱(MVP)입니다.

**상태:** Google Play 스토어 첫 배포 완료 (0.1.2+2, 2026-06-21). 이후 0.3.3까지 내부 카탈로그 다양화, 안정성 최적화, AdMob 연동이 반영된 상태입니다. 상세 변경 이력은 `CHANGELOG.md`를 참고하세요.

## 핵심 방향

- YouTube 오디오를 추출하지 않습니다.
- YouTube 영상을 다운로드하거나 캐시하지 않습니다.
- 모든 재생은 공식 **YouTube 임베드 플레이어**로만 이루어집니다.
- 공식 플레이어/컨트롤 위를 덮지 않습니다.
- 백그라운드 재생은 포함하지 않습니다.
- API 키가 없으면 mock 데이터로 동작합니다.
- UI는 **영어·한국어·중국어(간체)** 3개 언어를 지원합니다. 기기 언어를 자동(`auto`)으로 따르며, 설정에서 수동 선택(`auto` / `en` / `ko` / `zh`)도 가능합니다. 세 언어는 `AppText._pick(ko, en, zh)` 헬퍼로 동기화합니다.

## 다국어 / i18n

- 3개 언어 현지화는 `AppText`에 모여 있습니다. 단순 문자열은 `_pick(ko, en, zh)`를 쓰고, 표 형태(`moodName`, `moodDescription`, `category`, `tag`)는 `ko`/`en`/`zh` 맵을 각각 가집니다.
- 로케일 연결: `supportedLocales` = en/ko/zh, `effectiveLanguageCode()`는 `auto`→기기→en 순으로 매핑, `dialMoodPresets`의 무드명도 현지화됩니다.
- 기기에서 중국어 렌더링은 시스템 CJK 폰트를 사용합니다. `fontFamilyFallback`에 한국어 Noto보다 앞서 `PingFang SC` / `Noto Sans SC` / `Noto Sans CJK SC`를 둡니다. (**웹** 미리보기에서는 일부 CJK 글자가 두부(□)로 보일 수 있으나, 이는 브라우저 폰트 fallback 한계이며 안드로이드에서는 정상입니다.)

## 테마 (라이트 / 다크)

- 설정의 선택기로 **시스템 / 라이트 / 다크**를 지원합니다(`MoodTubeState.themeMode`, 영속 저장).
- `DesignTokens`는 **밝기-반응형**입니다. 표면/텍스트/그림자는 `DesignTokens.brightness` 기준 getter이고, 액센트(violet/rose/blue/`moodPalette`)는 라이트·다크 공통입니다. `MoodTubeApp`이 밝기를 해석(시스템 모드면 기기 따라감)한 뒤 빌드 전에 `DesignTokens.brightness`를 설정하므로, 커스텀 오로라 위젯도 함께 전환됩니다.
- `SoftBackdrop`은 `ValueKey(DesignTokens.isDark)`로 키잉되어 테마 전환 시 백드롭이 다시 그려집니다.
- **새 표면색은 반드시 토큰을 사용**(`panel`/`sheet`/`panelAlt`/`ink`/`sage`/`muted`/`cardBorder`)하세요. 흰색을 하드코딩하면 다크모드가 깨집니다. 토큰 색을 쓰는 `const TextStyle`은 `const`를 빼야 합니다.

## 접근성 및 햅틱 피드백

- 다이얼 노드 탭/드래그 변경 시 `HapticFeedback.selectionClick()`, 북마크 토글 시 `lightImpact()`, 중앙 재생 버튼(`_CenterPlay`) 클릭 시 `mediumImpact()` 햅틱이 작동하여 터치 반응이 세분화되었습니다.
- 아이콘 전용 컨트롤에 `Semantics` 라벨이 있습니다(`_CircleIconButton` 검색/프로필, `_CenterGlowButton` 이퀄라이저, 다이얼 노드, 북마크 버튼).
- 터치 타깃은 48dp를 지향하며, 보관함 빈 상태에는 탐색 탭으로 이동하는 "탐색에서 저장" 액션이 있습니다.

## 릴리즈 & 서명 (Play 출시 준비)

- `applicationId` / `namespace` = `com.moodtube.app` (기존 placeholder `com.example.moodtube`에서 변경). `MainActivity.kt`는 `com/moodtube/app/`로 이동.
- 릴리즈 서명은 `android/key.properties`(gitignore) → `android/app/upload-keystore.jks`(gitignore)를 읽습니다. `key.properties`가 없으면 debug 서명으로 폴백하여 개발 빌드는 그대로 됩니다. 템플릿은 `android/key.properties.example`을 참고하세요.
- **키스토어는 로컬 전용이며 커밋되지 않습니다.** `key.properties`와 keystore 파일은 로컬에만 두고, 프로젝트 외부의 안전한 백업 매체에도 보관하세요. 분실하면 앱 업데이트가 영구 불가합니다.
- R8/코드 축소 및 난독화가 활성화되어 있습니다. (`minifyEnabled true`, `shrinkResources true`, `proguard-rules.pro` 규칙 연동)
- AAB 검증을 위해 네이티브 심볼을 포함합니다. (`debugSymbolLevel = "SYMBOL_TABLE"`) 이 때문에 업로드용 AAB 용량은 늘지만, Play가 기기별로 최적화해 배포하므로 사용자 설치 용량과는 별개입니다.
- 2026-06-13 검증 기준 `flutter build apk --release` 성공(약 56.4MB) 및 `flutter build appbundle --release` 성공(약 57.7MB). AAB 내부에 `libflutter.so.sym` / `libapp.so.sym` 포함 확인.

## 앱 아이콘 & 스플래시

- **다이얼 모티프 오로라 아이콘**: 반원 게이지 아크(blue→violet→rose) + 틱 + 흰색 재생 디스크로, 앱 내 무드 다이얼과 동일한 느낌. 라벤더→핑크 그라데이션 배경. 레거시 PNG는 `mipmap-*`, 적응형 아이콘은 `mipmap-anydpi-v26/ic_launcher.xml` + `drawable/ic_launcher_background.xml` + `ic_launcher_foreground.png`.
- 스플래시(`drawable/launch_background.xml`) = 부드러운 오로라 그라데이션 + 가운데 `splash_logo.png`.
- 재생성: Pillow venv 사용 `/tmp/moodtube_iconenv/bin/python /tmp/gen_moodtube_icon2.py` (다이얼 모티프 생성기).

## 개인정보처리방침

- `docs/PRIVACY.md`(en/ko/zh) + 호스팅 가능한 `docs/privacy.html`.
- 공개 URL: `https://legitstudio.cc/moodtube/privacy` (Play Console 개인정보처리방침 URL로 사용)

## UI 디자인 기준 — "Mood Spectrum" (2026-06-12 전면 리뉴얼)

UI는 2026-06-12에 **"Mood Spectrum" 에디토리얼 다크 퍼스트** 스타일로 전면 리빌딩되었습니다(기존 파스텔 오로라/글래스모피즘 대체). 앞으로의 MoodTube 화면/컴포넌트는 이 기준을 따릅니다. **명시적 요청 없이 이전 파스텔 오로라나 뉴모피즘으로 되돌리지 마세요.**

- **핵심 아이덴티티**: 감정의 스펙트럼을 상징하는 **시그니처 4색 그라데이션** `DesignTokens.spectrum`(블루 `#5b8cff` → 바이올렛 `#8b5cf6` → 로즈 `#ff5e8a` → 엠버 `#ff8a56`). 워드마크("Mood" 부분), 다이얼 게이지, 중앙 버튼, 헤더 액센트 바, 추천 배지 등 **브랜드가 드러나야 하는 곳에만** 사용 — 스펙트럼이 유일하게 화려한 요소이고 나머지 표면은 조용하게 유지합니다.
- 표면: 다크는 딥 잉크(`#0a0a10` 배경 / `#15151e` 패널), 라이트는 따뜻한 페이퍼(`#f6f5f2` / 흰색 패널). 구조는 **헤어라인 보더**(`cardBorder`)가 담당하고 그림자는 은은한 힌트 수준(`softShadow`/`smallShadow`/`cardShadow`).
- 배경: `SoftBackdrop`이 절제된 스펙트럼 글로우를 상단 모서리에만 살짝 깔아줍니다(`_AuroraBackdropPainter`). 콘텐츠와 경쟁하지 않을 만큼만.
- 타이포그래피: **대비로 위계 표현** — 제목은 w800 + 자간 -0.5~-1.0, 본문/보조는 w500~w600. w900 사용 금지, 최소 글자 크기 12.
- 워드마크: 홈 헤더에서 "Mood"는 스펙트럼 `ShaderMask`, "Tube"는 잉크색 — 로고 자체가 브랜드.
- 홈: 워드마크+날짜 헤더 → 인라인 무드 다이얼(반원 게이지, 스펙트럼 호) → 콘텐츠 시트(빠른 무드 칩 → 스마트 픽 → "무드로 둘러보기" 그리드 + **명시적 새로고침 버튼**).
- 무드 다이얼(`AuroraMoodDial`): 반원 게이지의 채움 호가 스펙트럼 그라데이션. 중앙 재생 버튼(`_CenterPlay`)과 하단 네비 가운데 버튼(`_CenterGlowButton`, 이퀄라이저 아이콘)도 동일한 스펙트럼 원형. 노드/노브/틱은 전부 토큰 기반이라 다크모드 자동 대응.
- 헤더(`PremiumHeader`): 박스 카드 없이 **스펙트럼 세로 바(4×58) + 대형 타이트 타이틀**의 에디토리얼 스타일. 탐색/보관함/설정 공용.
- 스마트 픽(`SmartPickCard`): 썸네일+재생 오버레이, 제목, (해당 시) 스펙트럼 **"추천 채널" 배지**, 장르 태그, **누적 재생 수**("~회 재생" — "듣는 중" 표현 금지), 시:분:초, 북마크.
- 에러 상태: 예외 메시지를 그대로 노출하지 않고 아이콘 + `AppText.genericError`(3개 언어) 사용.
- 인터랙션: 검색, 무드 카드, 저장, 재생, 언어/테마 설정 등 기존 동작은 디자인 변경 중에도 보존.

주요 구조: 기능별 16개 독립 모듈 구조로 분산 리팩토링되었습니다. 디자인 시스템은 `DesignTokens`(+`spectrum`/`spectrumGradient`), `softPanelDecoration`, `auroraPanelDecoration`, `SoftBackdrop`, `AuroraMoodDial`, `MoodDialSheet`, `QuickMoodChip`, `SmartPickCard`, `PremiumHeader`, `_CenterGlowButton`, `StatusDot`에 있습니다.

## 검색, 스마트 픽, 재생

- 탐색 검색은 입력한 자유 텍스트를 그대로 사용합니다. API 모드에서는 사용자 검색어 + 긴 플레이리스트 의도를 더해 YouTube Data API로 검색하고, 키가 없거나 API 실패 시 로컬 mock 결과로 폴백합니다.
- 스마트 픽은 최신 검색 결과 기반입니다. 조회수 높은 긴 플레이리스트를 우선하며, 검색 후 Scapetune 결과 1개를 섞습니다. **스포트라이트 채널의 픽에는 스펙트럼 "추천 채널" 배지가 표시**되어 큐레이션임을 투명하게 알립니다.
- Scapetune 소스: `https://www.youtube.com/@my_scapetune`. API 모드에서 핸들을 YouTube Data API로 해석해 해당 채널 안에서 Scapetune 슬롯을 찾습니다.
- 홈 무드 그리드는 8개 이상의 카테고리가 있지만 8개만 보여줍니다. 자주 검색한 무드가 그리드로 올라오고, "무드로 둘러보기" 옆 **새로고침 버튼**으로 조합을 갱신합니다(이전의 "끝까지 스크롤 시 자동 갱신"은 혼란을 줘서 제거).
- 결과 카드의 재생 버튼은 전체 플레이어를 즉시 열고 하단 미니 플레이어의 현재 항목도 설정합니다. 플레이어에서 돌아와도 미니 플레이어는 유지됩니다.
- `유튜브에서 열기`는 인앱 브라우저 뷰를 사용해, 사용자가 YouTube 앱에 갇히지 않고 MoodTube로 닫고/돌아올 수 있게 합니다.

## 실행

Flutter가 준비된 환경에서:

```bash
cd MoodTube
flutter pub get
flutter run
```

수동 scaffold로 열려 Flutter/Gradle 래퍼 파일이 없다면, Flutter 설치 후 안드로이드 플랫폼 파일을 재생성하세요:

```bash
cd MoodTube
flutter create --platforms=android .
flutter pub get
flutter run
```

## 릴리즈 빌드

로컬 시크릿 파일을 준비한 뒤 빌드합니다:

```bash
cp dart_defines.json.example dart_defines.json
# dart_defines.json에 YouTube Data API 키 입력 (Android 패키지 + SHA-1로 제한 권장)
cp android/key.properties.example android/key.properties
# key.properties와 upload-keystore.jks 설정

flutter build appbundle --release --dart-define-from-file=dart_defines.json
```

API 키 없이도 앱은 `mockCatalog`로 동작합니다.

## 빠른 웹 미리보기 (브라우저)

기기/에뮬레이터 없이 브라우저에서 폰 프레임으로 미리보기:

```bash
cd MoodTube
./preview.sh            # 웹을 빌드한 뒤 폰 프레임 미리보기를 서빙
```

그런 다음 <http://localhost:5198/preview.html>을 엽니다(스크립트가 자동으로 열기도 합니다).
미리보기 페이지에는 모바일 / 소형 / 전체폭 전환 및 새로고침 버튼이 있습니다.

- `./preview.sh --serve`는 빌드를 건너뛰고 기존 `build/web`만 서빙합니다.
- 코드를 바꾼 뒤에는 `./preview.sh`를 다시 실행해 재빌드하세요.
- 폰 프레임 래퍼 템플릿은 `tools/preview-frame.html`이며, 스크립트가 실행마다 `build/web/preview.html`로 복사합니다.
- 참고: 임베드 YouTube 플레이어는 웹을 지원하지 않으므로 재생은 실제 안드로이드 앱에서만 됩니다 — 웹 미리보기는 시각/레이아웃 확인용입니다.

## 추천 로직 / YouTube API 사용

- **YouTube Data API**: 빌드 시 `--dart-define-from-file=dart_defines.json`으로 키를 주입합니다. 키가 없거나 할당량 초과·오프라인이면 `mockCatalog`로 폴백합니다.
- **에너지 무드 매핑**: 다이얼의 감정 무드(`mood_*`)는 `atmosphereToActivities`로 활동 무드 카탈로그에 매핑되어 내부 데이터로 추천됩니다.
- **YouTube Data API는 제한적**: API는 `apiMode`가 켜져 있고 키가 있을 때만, 그리고 `kDailyApiSearchLimit`(기기당 일일 상한, 기본 12회) 안에서만 호출됩니다. 그 외에는 항상 내부 카탈로그를 사용해 공유 할당량을 보호합니다.
- API 키는 소스에 포함하지 않습니다. `dart_defines.json.example`을 복사해 로컬 `dart_defines.json`에 설정하세요.
- 안드로이드 인터넷 권한은 `android/app/src/main/AndroidManifest.xml`에 포함되어 있습니다.

## 광고(수익화)

- **연동 상태**: `google_mobile_ads` 적용. AdMob 앱 ID는 매니페스트에 등록(`ca-app-pub-9993388177095923~4694181215`). 홈 "스마트 픽" 3번째 카드 뒤에 광고 슬롯(`ads.smartPickAd()`) 삽입.
- **연동 및 승인 완료 (2026-07-05)**: 구글 플레이 스토어 배포 후 AdMob 콘솔에서 `com.moodtube.app` 앱 연동을 성공적으로 마쳤습니다. 앱 인증(`확인됨`) 및 승인 상태(`준비됨`)가 완료되어 실광고 노출이 활성화되었습니다.
- **설정 보완 완료**: `app-ads.txt` 크롤링 수집 확인, 업로드 키스토어 백업, 그리고 Google Cloud Console의 YouTube API 키 제한사항에 Google Play 앱 서명 키의 SHA-1 지문 등록 조치가 완비되었습니다.
- **웹 안전**: `lib/ads/`는 조건부 임포트(`ads.dart` → 모바일 `ads_real.dart` / 웹 `ads_stub.dart`)라 웹 빌드/미리보기에는 광고 SDK가 들어가지 않습니다.
- 모바일 릴리즈는 실제 광고 단위 ID를 사용합니다(`ads_real.dart`, release/debug 분기). 에뮬레이터/미승인 상태에서는 광고 로드 실패가 로그에 보일 수 있으나 앱 시작을 막지 않도록 초기화 실패를 흡수합니다.
- ⚠️ **Play 제출 전 Data Safety에 'AdMob 사용(광고 식별자 등)'을 반영**해야 합니다. 개인정보처리방침은 AdMob/AD_ID 반영 및 호스팅 완료.
- 자세한 가이드: `docs/ADS_GUIDE.md` (AdMob 가입·배치·세팅·정책).

## 2026-06-21 버전 0.1.2 (버전코드 2) Google Play Console 출시 완료

- **최종 기능 보완 및 성능 최적화 완료**:
  1. **유튜브 재생오류 자동 차단 (블랙리스트 필터링)**: 재생 오류 발생 영상을 로컬 블랙리스트에 저장하여 모든 화면에서 배제 및 재생 스킵 처리.
  2. **무드 다이얼 드래그 렉 해결**: 다이얼 조작 시 부모 갱신을 드래그 종료 시점 1회로 격리하여 60FPS 급 부드러운 UX 구현.
  3. **바텀 시트 다이얼 레이아웃 정렬 및 플레이버튼 치우침 해결**: `FittedBox`와 헤더 위젯 단일화를 적용하여 다이얼 레이아웃을 완벽히 일치시킴.
  4. **카테고리/검색 화면 뒤로가기 재생 유지**: `ResultsScreen`에 `MiniPlayer`를 탑재하여 뒤로 돌아가더라도 오디오가 지속되도록 개선.
- **빌드 및 검증**: `flutter analyze` 경고 0개, `flutter test` 8개 전원 통과.
- **최종 파일**: 버전코드 `2`가 내장된 `app-release_v0.1.2.apk` 및 `app-release_v0.1.2.aab` 배포 제출 완료.
- **용량 메모**: 프로젝트 폴더가 커진 주원인은 `build/` 캐시(약 3.0GB). 출시 파일 자체는 `app-release_v0.1.2.aab` 약 58MB, `app-release_v0.1.2.apk` 약 56MB.

---

## 2026-06-28 내부 카탈로그 다양화 & 앱 안정성 최적화 업데이트 (버전 0.1.2 배포 이후)

- **mockCatalog 비디오 소스 다양성 보강**:
  - API 키 할당량 제한이나 오프라인 모드일 때 매칭되는 곡의 스펙트럼을 넓히기 위해 실제 존재하는 안정적이고 대중적인 유튜브 플레이리스트 비디오 ID 8개를 추가로 선정하여 반영했습니다.
  - 추가 영상: `Lofi Girl` (lofi sleep beats, morning lofi, synthwave), `Classic FM` (Chopin, Mozart), `Rainy Day` (Rain Sounds), `Nature Ambience` (Birds Singing), `Cafe Music BGM` (Jazz & Bossa Nova) 등의 유명 비디오 소스 수집.
  - `lib/data/mock_catalog.dart` 및 `lib/main.dart` 두 위치의 `mockCatalog` 데이터를 일치하여 업데이트 완료.
- **네트워크 연결 상태 확인 및 타임아웃 처리 (stability_plus)**:
  - `connectivity_plus` 패키지를 도입하여 네트워크 연결이 없는 환경에서 YouTube API 호출을 사전에 차단하고 매끄럽게 오프라인 모드(mockCatalog)로 전환하도록 처리했습니다.
  - YouTube API 호출에 `15초` 타임아웃(`kHttpTimeout`) 제한을 설정하여 불안정한 네트워크 대기 문제를 방지했습니다.
- **이미지 로딩 최적화**:
  - `cached_network_image` 패키지를 도입하여 결과 화면(`ResultsScreen`) 및 보관함(`LibraryScreen`)의 썸네일 이미지에 네트워크 캐싱을 적용해 응답 속도를 개선하고 불필요한 트래픽 소모를 방지했습니다.
- **비동기 예외 및 생명주기(Lifecycle) 안전성 보강**:
  - `PlayerScreen`이 dispose될 때 컨텍스트가 유효하지 않아 생길 수 있는 문제를 방지하고자 `initState`에서 `MoodTubeState` 인스턴스(`_tubeState`)를 미리 캡처해 두었다가 안전하게 사용하도록 리팩토링했습니다.
  - `MoodTubeState` 내부의 API 할당량 체크(`_allowApiCall()`)를 완전 비동기 `Future<bool>`와 `await` 구조로 단순화해 가독성을 높였습니다.
- **테스트 무결성 검증**:
  - 정적 분석 `flutter analyze` 결과 **경고 및 오류 없음(No issues found!)**
  - 단위 및 위젯 테스트 `flutter test` 결과 **8개 테스트 전원 정상 패스**
  - 빌드 전 컴파일 무결성을 보장하며 0.1.2 배포 버전 이후 안정적인 로컬 리소스로 유지됩니다.
