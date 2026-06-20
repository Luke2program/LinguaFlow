#!/bin/zsh
# ci_post_clone.sh - Xcode Cloud Post Clone Script for QuestFlow
# This script runs after the repository is cloned

echo "🚀 QuestFlow - Xcode Cloud Post Clone"
echo "========================================"

# Show environment info
echo "📱 Building for iOS"
echo "📁 Working directory: $(pwd)"
echo "🔀 Branch: $CI_BRANCH"
echo "🏷️ Commit: $CI_COMMIT"

# Install dependencies if needed (e.g., CocoaPods, Swift Package Manager)
# For SPM projects, dependencies are resolved automatically

# Check Xcode version
echo "🛠️ Xcode Version:"
xcodebuild -version

echo "✅ Post clone setup complete!"
