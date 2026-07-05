#!/bin/bash
# MoodTube 웹 미리보기 — 브라우저에서 폰 프레임으로 앱을 확인합니다.
# 사용법:  ./preview.sh           (빌드 후 미리보기)
#          ./preview.sh --serve   (재빌드 없이 기존 빌드만 띄우기)
set -e
cd "$(dirname "$0")"

PORT=5198

if [ "$1" != "--serve" ]; then
  echo "▶ MoodTube 웹 빌드 중... (40초 내외, 처음만 오래 걸립니다)"
  flutter build web
fi

if [ ! -f build/web/index.html ]; then
  echo "✗ build/web 이 없습니다. 먼저 './preview.sh' 로 빌드하세요."
  exit 1
fi

# 폰 프레임 미리보기 페이지를 빌드 폴더에 복사
cp tools/preview-frame.html build/web/preview.html

URL="http://localhost:${PORT}/preview.html"
echo ""
echo "✓ 미리보기 준비 완료"
echo "  → 브라우저에서 열기:  ${URL}"
echo "  (종료하려면 이 터미널에서 Ctrl+C)"
echo ""

# 브라우저 자동 열기 (macOS)
( sleep 1; open "${URL}" >/dev/null 2>&1 || true ) &

# 정적 서버 실행 (build/web 루트)
python3 -m http.server "${PORT}" --directory build/web
