#!/bin/bash
# mock_catalog.dart의 모든 videoId가 실존하는지 검사합니다.
# 1) oEmbed가 200을 주는지 (영상 존재/공개 여부)
# 2) hqdefault.jpg가 200을 주는지 (썸네일 존재 여부 — 없으면 카드가 회색으로 보임)
# 사용법: ./tools/check_catalog.sh
set -e
cd "$(dirname "$0")/.."

CATALOG="lib/data/mock_catalog.dart"
IDS=$(grep -oE "mockVideo\(\s*'[A-Za-z0-9_-]{11}'" "$CATALOG" | grep -oE "'[A-Za-z0-9_-]{11}'" | tr -d "'" | sort -u)

BAD=0
for id in $IDS; do
  oembed=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 \
    "https://www.youtube.com/oembed?url=https%3A//www.youtube.com/watch%3Fv%3D${id}&format=json")
  thumb=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 \
    "https://img.youtube.com/vi/${id}/hqdefault.jpg")
  if [ "$oembed" != "200" ] || [ "$thumb" != "200" ]; then
    echo "✗ $id  (oembed=$oembed thumb=$thumb)"
    BAD=$((BAD+1))
  fi
done

TOTAL=$(echo "$IDS" | wc -l | tr -d ' ')
if [ "$BAD" -eq 0 ]; then
  echo "✓ 전체 ${TOTAL}개 영상 ID 정상 (영상 존재 + 썸네일 존재)"
else
  echo ""
  echo "⚠ ${TOTAL}개 중 ${BAD}개가 죽었거나 썸네일이 없습니다. 교체가 필요합니다."
  exit 1
fi
