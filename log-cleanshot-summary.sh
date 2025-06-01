#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Homy CleanShot Summary
# @raycast.mode compact
# @raycast.icon 📊

SCREENSHOTS_DIR="$HOME/homy-ui-v3/docs/screenshots"
LOG_FILE="$HOME/homy-ui-v3/docs/cleanshot-activity.md"
TODAY=$(date +"%Y-%m-%d")

# Create header if log file doesn't exist
if [ ! -f "$LOG_FILE" ]; then
  echo "# 📸 CleanShot Activity Log" > "$LOG_FILE"
  echo "" >> "$LOG_FILE"
fi

# Find today's screenshots
echo "## 📅 $TODAY" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Loop through component directories
for component_dir in "$SCREENSHOTS_DIR"/*/ ; do
  if [ -d "$component_dir" ]; then
    component=$(basename "$component_dir")
    # Count today's screenshots for this component
    count=$(find "$component_dir" -type f -name "*$(date +%d-%B-%Y)*.png" | wc -l)
    
    if [ "$count" -gt 0 ]; then
      echo "### 🎯 $component" >> "$LOG_FILE"
      echo "- Added $count new screenshots" >> "$LOG_FILE"
      # List the actual files
      find "$component_dir" -type f -name "*$(date +%d-%B-%Y)*.png" -exec basename {} \; | while read -r file; do
        echo "  - \`$file\`" >> "$LOG_FILE"
      done
      echo "" >> "$LOG_FILE"
    fi
  fi
done

echo "✅ Daily summary updated in: $LOG_FILE" 