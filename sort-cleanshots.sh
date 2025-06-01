#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title CleanShot → Homy
# @raycast.mode compact
# @raycast.icon 📸
# @raycast.packageName Homy Tools
# @raycast.description CleanShot görsellerini taşı ve README'ye logla

INBOX="$HOME/Desktop/CleanShot-Capture"
PROJECT="$HOME/homy-ui-v3"
SCREENSHOTS_DIR="$PROJECT/docs/screenshots"
TODAY=$(date +"%d.%m.%Y")

echo "📂 Tarama başlıyor: $INBOX klasörü"

for file in "$INBOX"/*.png; do
  [[ -e "$file" ]] || { echo "⛔ Hiç .png dosyası bulunamadı."; exit 1; }

  FILENAME=$(basename "$file")
  echo "🔍 Bulundu: $FILENAME"

  COMPONENT=$(echo "$FILENAME" | grep -o '\[[^]]*\]' | head -n 1 | tr -d '[]' | tr '[:upper:]' '[:lower:]')

  if [[ -n "$COMPONENT" ]]; then
    echo "✅ Bileşen algılandı: $COMPONENT"

    TARGET_DIR="$SCREENSHOTS_DIR/$COMPONENT"
    mkdir -p "$TARGET_DIR"

    mv "$file" "$TARGET_DIR/$FILENAME"

    echo "📸 $TODAY: [$COMPONENT] → $FILENAME" >> "$TARGET_DIR/README.md"
    echo "✅ Taşındı: $FILENAME → $COMPONENT/"
  else
    echo "⚠️ Bileşen ismi çıkarılamadı: $FILENAME"
    echo "📂 Hedef dizin: $SCREENSHOTS_DIR/$COMPONENT"
  fi
done