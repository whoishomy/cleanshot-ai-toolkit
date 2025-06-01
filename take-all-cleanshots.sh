#!/bin/bash

# CleanShot Automation Pipeline (CSAP)
# Created by Claude for HOMY UI v3
# Usage: ./scripts/take-all-cleanshots.sh

# Create necessary directories
mkdir -p docs/screenshots/{dashboard,lab-result,mobile-dashboard,focus-coach,insight-overlay}

# Function to display status
show_status() {
    echo "📸 Taking screenshot: $1"
}

# Ensure dev server is running
if ! curl -s http://localhost:3005 > /dev/null; then
    echo "⚠️  Starting development server..."
    npm run dev &
    sleep 10
fi

# Mobile Dashboard Screenshots
show_status "mobile-dashboard/dashboard-main"
bash ./scripts/take-cleanshot.sh mobile-dashboard main 390

show_status "mobile-dashboard/tabs-switch-daily"
bash ./scripts/take-cleanshot.sh mobile-dashboard tabs-daily 390

show_status "mobile-dashboard/tabs-switch-weekly"
bash ./scripts/take-cleanshot.sh mobile-dashboard tabs-weekly 390

show_status "mobile-dashboard/health-score-trend"
bash ./scripts/take-cleanshot.sh mobile-dashboard trend 390

show_status "mobile-dashboard/category-distribution"
bash ./scripts/take-cleanshot.sh mobile-dashboard category 390

# Wait for all screenshots to complete
sleep 2

# Update documentation
echo "✨ Updating screenshot documentation..."
npm run docs:screenshots

echo "✅ All screenshots captured successfully!"
osascript -e 'display notification "✅ All screenshots captured!" with title "HOMY UI"' 