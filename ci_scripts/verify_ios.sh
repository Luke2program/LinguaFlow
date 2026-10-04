#!/bin/bash
# Keep test failures visible while retaining logs and UI-test screenshot attachments.
set -euo pipefail
cd "$(dirname "$0")/.."
artifact_root="${VERIFICATION_OUTPUT_DIR:-build/verification}"
mkdir -p "$artifact_root"
run_dir="$(mktemp -d "$artifact_root/run.XXXXXX")"
git rev-parse HEAD > "$run_dir/revision.txt"
printf "Verification evidence: %s\n" "$run_dir"
xcodebuild test \
  -project LinguaFlow.xcodeproj \
  -scheme LinguaFlow \
  -destination "${IOS_TEST_DESTINATION:-platform=iOS Simulator,name=iPhone 17 Pro,OS=latest}" \
  -parallel-testing-enabled NO \
  -derivedDataPath "$run_dir/DerivedData" \
  -resultBundlePath "$run_dir/TestResults.xcresult" \
  2>&1 | tee "$run_dir/xcodebuild.log"
