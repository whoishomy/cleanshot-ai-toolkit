#!/bin/bash

# Check if a component name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <component-name>"
  exit 1
fi

COMPONENT_NAME="$1"

# Run the rename script
bash scripts/rename-last-cleanshot.sh "$COMPONENT_NAME"

# Run the sort script
bash scripts/sort-cleanshots.sh

# Generate daily summary
bash scripts/log-cleanshot-summary.sh

echo "✅ CleanShot flow completed for component: $COMPONENT_NAME"
echo "📊 Daily summary updated in docs/cleanshot-activity.md" 