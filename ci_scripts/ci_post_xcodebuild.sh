#!/bin/zsh
# ci_post_xcodebuild.sh - Xcode Cloud Post-Build Script for QuestFlow
# This script runs after the build completes

echo "🎯 QuestFlow - Post Build"
echo "==========================="

# Check build result
if [ "$CI_XCODEBUILD_EXIT_CODE" = "0" ]; then
    echo "✅ BUILD SUCCESSFUL"
    
    # Upload to TestFlight if this is a main branch build
    if [ "$CI_BRANCH" = "main" ] || [ "$CI_BRANCH" = "master" ]; then
        echo "🚀 Ready for TestFlight upload"
        # Xcode Cloud handles TestFlight upload automatically if configured
    fi
else
    echo "❌ BUILD FAILED with exit code: $CI_XCODEBUILD_EXIT_CODE"
fi

# Show test results if available
if [ -d "$CI_RESULT_BUNDLE_PATH" ]; then
    echo "📊 Test Results available at: $CI_RESULT_BUNDLE_PATH"
fi

echo "🎉 Build process complete!"
