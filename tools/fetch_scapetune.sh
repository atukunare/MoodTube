#!/bin/bash
# Fetch recent videos from the @my_scapetune YouTube channel (no API key needed)
# so you can refresh the bundled `_scapetuneSpotlights` list in lib/main.dart.
#
# Usage:  ./tools/fetch_scapetune.sh
set -e
CID="UCCZge1CJ4Z-gcfEVRIAihzA"   # @my_scapetune
echo "Fetching RSS for channel $CID ..."
curl -s "https://www.youtube.com/feeds/videos.xml?channel_id=$CID" -o /tmp/scape.xml
python3 - <<'PY'
import re
x = open('/tmp/scape.xml', encoding='utf-8').read()
for e in re.findall(r'<entry>.*?</entry>', x, re.S):
    vid = re.search(r'<yt:videoId>([^<]+)', e)
    title = re.search(r'<title>([^<]+)', e)
    pub = re.search(r'<published>([^<]+)', e)
    if vid and title:
        t = title.group(1).replace('&amp;', '&')
        print(f"{vid.group(1)} | {t} | {pub.group(1)[:10] if pub else ''}")
PY
echo ""
echo "→ Pick the music/playlist ones (skip #shorts) and update _scapetuneSpotlights in lib/main.dart."
