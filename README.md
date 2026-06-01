# LinguaFlow

LinguaFlow is a native SwiftUI vocabulary trainer for German and Spanish learners. It combines CEFR-level onboarding, bidirectional vocabulary practice, offline speech audio, and an SM-2 inspired spaced repetition scheduler in a small iOS app that is easy to inspect and adapt.

The project is useful as:

- a practical language-learning app
- a reference SwiftUI implementation for spaced repetition
- a compact example of local-first learning state, streaks, XP, and due-card scheduling
- a testable iOS codebase for experimenting with Codex-assisted app maintenance

## Features

- German to Spanish and Spanish to German review directions
- CEFR level choice: A1, A2, B1, B2, C1
- Embedded essential speaking vocabulary and phrase cards
- SM-2 inspired scheduler with ease, interval, lapse handling, and due queues
- Offline audio through `AVSpeechSynthesizer`
- Daily streaks, XP, gems, combo feedback, and fluency meter
- SwiftUI interface with accessibility identifiers for UI tests
- Unit tests for scheduler, answer evaluation, and vocabulary data
- UI tests for review flow, settings, and account entry points

## Screens

The current app includes:

- onboarding and level selection
- daily review dashboard
- typed answer practice
- direction switching
- settings and language controls
- optional account/auth flows

## Getting Started

Requirements:

- macOS with Xcode
- iOS Simulator
- Swift 5 / current Xcode toolchain

Clone and open:

```bash
git clone https://github.com/Luke2program/LinguaFlow.git
cd LinguaFlow
open LinguaFlow.xcodeproj
```

Run tests:

```bash
xcodebuild test \
  -project LinguaFlow.xcodeproj \
  -scheme LinguaFlow \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  -parallel-testing-enabled NO
```

Build only:

```bash
xcodebuild build \
  -project LinguaFlow.xcodeproj \
  -scheme LinguaFlow \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -configuration Debug \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO
```

## Architecture

Important files:

- `LinguaFlow/AppModels.swift` defines vocabulary cards, levels, review state, and app models.
- `LinguaFlow/Scheduler.swift` contains the spaced repetition scheduling logic.
- `LinguaFlow/VocabularyData.swift` contains bundled starter vocabulary.
- `LinguaFlow/AppStore.swift` manages learning progress and persistence.
- `LinguaFlow/Views.swift` contains the main SwiftUI learning experience.
- `LinguaFlowTests/LinguaFlowTests.swift` covers scheduler and answer-evaluation behavior.
- `LinguaFlowUITests/LinguaFlowUITests.swift` covers user-facing learning flows.

## Maintainer Automation

This repository uses [Maintainer Signal](https://github.com/Luke2program/maintainer-signal) to generate weekly issue-triage and release-note reports. That keeps the project maintainable as more vocabulary, languages, and learning modes are added.

## Roadmap

- Add more language pairs beyond German and Spanish
- Import/export custom decks
- Add richer CEFR placement diagnostics
- Add pronunciation scoring
- Improve offline-first sync conflict handling
- Publish a small reusable Swift package for the scheduler

## Contributing

Contributions are welcome. Good first areas:

- add vocabulary cards with CEFR tags
- improve scheduling tests
- polish accessibility labels
- add localization strings
- improve docs for language learners and SwiftUI developers

See `CONTRIBUTING.md` for details.

## License

MIT
