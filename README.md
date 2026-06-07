# LinguaFlow

A native iOS German ↔ Spanish vocabulary trainer with CEFR level onboarding, Anki-style spaced repetition, offline speech audio, streaks, XP, and a fluid fluency indicator.

## Core features
- German → Spanish and Spanish → German review directions
- CEFR level choice: A1, A2, B1, B2, C1
- Embedded essential speaking vocabulary and phrase cards
- SM-2 inspired Anki scheduler with ease, interval, lapse handling, and due queues
- Offline audio via AVSpeechSynthesizer for German and Spanish
- Daily streaks, XP, gems, combo feedback, and fluency meter
- Native SwiftUI liquid-glass visual style using materials, gradients, and haptics

## Test command
```bash
xcodebuild test -project LinguaFlow.xcodeproj -scheme LinguaFlow -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -parallel-testing-enabled NO
```
