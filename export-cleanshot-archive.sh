#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Export CleanShot Archive
# @raycast.mode compact
# @raycast.icon 📦

# Optional parameters:
# @raycast.argument1 { "type": "text", "placeholder": "Component name (optional)", "optional": true }

PROJECT_DIR="$HOME/homy-ui-v3"
SCREENSHOTS_DIR="$PROJECT_DIR/docs/screenshots"
ARCHIVE_DIR="$PROJECT_DIR/docs/archives"
TODAY=$(date +"%Y-%m-%d")
COMPONENT="$1"

# Create archives directory if it doesn't exist
mkdir -p "$ARCHIVE_DIR"

# Function to create component summary
create_summary() {
  local component=$1
  local summary_file="$ARCHIVE_DIR/temp_summary.md"
  
  echo "# 📸 $component Screenshots" > "$summary_file"
  echo "Generated: $TODAY" >> "$summary_file"
  echo "" >> "$summary_file"
  
  # Add component README if exists
  if [ -f "$SCREENSHOTS_DIR/$component/README.md" ]; then
    cat "$SCREENSHOTS_DIR/$component/README.md" >> "$summary_file"
  fi
  
  echo "" >> "$summary_file"
  echo "## 📊 Statistics" >> "$summary_file"
  echo "- Total Screenshots: $(ls "$SCREENSHOTS_DIR/$component"/*.png 2>/dev/null | wc -l)" >> "$summary_file"
  echo "- Last Updated: $(ls -t "$SCREENSHOTS_DIR/$component"/*.png 2>/dev/null | head -n1 | xargs basename 2>/dev/null)" >> "$summary_file"
}

if [ -n "$COMPONENT" ]; then
  # Export single component
  if [ ! -d "$SCREENSHOTS_DIR/$COMPONENT" ]; then
    echo "❌ Component directory not found: $COMPONENT"
    exit 1
  fi
  
  create_summary "$COMPONENT"
  ARCHIVE_NAME="homy-ui-screenshots-${COMPONENT}-${TODAY}"
  
  # Create archive
  cd "$SCREENSHOTS_DIR" && zip -r "$ARCHIVE_DIR/$ARCHIVE_NAME.zip" \
    "$COMPONENT" \
    "$ARCHIVE_DIR/temp_summary.md" \
    -x "*/.*" \
    && rm "$ARCHIVE_DIR/temp_summary.md"
    
  echo "✅ Exported $COMPONENT screenshots to $ARCHIVE_NAME.zip"
else
  # Export all components
  ARCHIVE_NAME="homy-ui-screenshots-all-${TODAY}"
  
  # Create main summary
  echo "# 📸 HOMY UI Screenshots Archive" > "$ARCHIVE_DIR/temp_summary.md"
  echo "Generated: $TODAY" >> "$ARCHIVE_DIR/temp_summary.md"
  echo "" >> "$ARCHIVE_DIR/temp_summary.md"
  
  # Add component summaries
  for component in "$SCREENSHOTS_DIR"/*/ ; do
    if [ -d "$component" ]; then
      component_name=$(basename "$component")
      echo "## $component_name" >> "$ARCHIVE_DIR/temp_summary.md"
      echo "- Screenshots: $(ls "$component"/*.png 2>/dev/null | wc -l)" >> "$ARCHIVE_DIR/temp_summary.md"
      echo "" >> "$ARCHIVE_DIR/temp_summary.md"
    fi
  done
  
  # Create archive
  cd "$SCREENSHOTS_DIR" && zip -r "$ARCHIVE_DIR/$ARCHIVE_NAME.zip" \
    . \
    "$ARCHIVE_DIR/temp_summary.md" \
    -x "*/.*" \
    && rm "$ARCHIVE_DIR/temp_summary.md"
    
  echo "✅ Exported all screenshots to $ARCHIVE_NAME.zip"
fi

# Show archive contents
echo "📦 Archive contents:"
unzip -l "$ARCHIVE_DIR/$ARCHIVE_NAME.zip" | tail -n +4 | head -n -2 