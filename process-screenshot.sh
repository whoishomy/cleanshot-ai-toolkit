#!/bin/bash

# Exit on error
set -e

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source environment variables if .env exists
if [ -f "$PROJECT_ROOT/.env" ]; then
    source "$PROJECT_ROOT/.env"
fi

# Check if required environment variables are set
if [ -z "$OPENAI_API_KEY" ] || [ -z "$NOTION_TOKEN" ] || [ -z "$NOTION_DATABASE_ID" ]; then
    echo "❌ Error: Required environment variables are not set"
    echo "Please ensure OPENAI_API_KEY, NOTION_TOKEN, and NOTION_DATABASE_ID are set in .env"
    exit 1
fi

echo "🚀 Starting screenshot processing pipeline..."

# Step 1: Sort the screenshot into the correct component directory
echo "📂 Sorting screenshot..."
"$SCRIPT_DIR/sort-cleanshots.sh"

# Step 2: Run AI tagging to generate description and tags
echo "🤖 Running AI tagging..."
npx ts-node --esm "$SCRIPT_DIR/ai-tag-cleanshots.ts"

# Step 3: Export to Notion
echo "📤 Exporting to Notion..."
npx ts-node --esm "$SCRIPT_DIR/notion-export-cleanshots.ts"

echo "✨ Screenshot processing complete!" 