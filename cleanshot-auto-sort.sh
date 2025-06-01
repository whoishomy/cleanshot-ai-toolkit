#!/bin/bash

# Base directories
SCREENSHOTS_DIR="docs/screenshots/lab-results"
CLEANSHOT_DIR="$HOME/Documents/CleanShot"  # Default CleanShot directory

# Create directories if they don't exist
mkdir -p "$SCREENSHOTS_DIR"/{normal,low,high,loading,error,trends}

# Function to move and rename files
move_and_rename() {
    local source=$1
    local category=$2
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local destination="$SCREENSHOTS_DIR/$category/lab-results-${category}-${timestamp}.png"
    
    mv "$source" "$destination"
    echo "✅ Moved to: $destination"
}

# Watch CleanShot directory for new screenshots
echo "🔍 Watching for new screenshots in $CLEANSHOT_DIR..."
echo "📂 Categories: normal, low, high, loading, error, trends"
echo "⚡️ Press Ctrl+C to stop"

fswatch -0 "$CLEANSHOT_DIR" | while read -d "" file; do
    if [[ "$file" =~ .*\.png$ ]]; then
        echo "📸 New screenshot detected: $file"
        echo "Select category:"
        echo "1) normal"
        echo "2) low"
        echo "3) high"
        echo "4) loading"
        echo "5) error"
        echo "6) trends"
        read -p "Enter number (1-6): " choice
        
        case $choice in
            1) move_and_rename "$file" "normal" ;;
            2) move_and_rename "$file" "low" ;;
            3) move_and_rename "$file" "high" ;;
            4) move_and_rename "$file" "loading" ;;
            5) move_and_rename "$file" "error" ;;
            6) move_and_rename "$file" "trends" ;;
            *) echo "❌ Invalid choice. Screenshot not moved." ;;
        esac
    fi
done 