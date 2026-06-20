#!/bin/zsh
# ci_pre_xcodebuild.sh - Xcode Cloud Pre-Build Script for QuestFlow
# This script runs before the build starts

echo "🔧 QuestFlow - Pre Build Setup"
echo "=================================="

# Set build number based on CI build number if available
if [ -n "$CI_BUILD_NUMBER" ]; then
    echo "📊 Setting build number to: $CI_BUILD_NUMBER"
    # Note: In Xcode Cloud, build numbers are managed automatically
fi

# Show build settings
echo "📋 Build Settings:"
echo "  Product: $CI_PRODUCT"
echo "  Scheme: $CI_XCODE_SCHEME"
echo "  Project: $CI_XCODE_PROJECT"

echo "✅ Pre-build setup complete!"
