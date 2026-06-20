# QuestFlow

A native iOS learning adventure with playable subjects, world-based challenges, spaced repetition for languages, streaks, XP, gems, and pet progression.

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

## Architecture

Important files:

- `LinguaFlow/AppModels.swift` defines vocabulary cards, levels, review state, and app models.
- `LinguaFlow/Scheduler.swift` contains the spaced repetition scheduling logic.
- `LinguaFlow/VocabularyData.swift` contains bundled starter vocabulary.
- `LinguaFlow/AppStore.swift` manages learning progress and persistence.
- `LinguaFlow/Views.swift` contains the main SwiftUI learning experience.
- `LinguaFlowTests/LinguaFlowTests.swift` covers scheduler and answer-evaluation behavior.
- `LinguaFlowUITests/LinguaFlowUITests.swift` covers user-facing learning flows.

For a contributor-oriented overview of the runtime flow, file map, and testing expectations, see `docs/architecture.md`.

## Maintainer Automation

This repository uses [Maintainer Signal](https://github.com/Luke2program/maintainer-signal) to generate weekly issue-triage and release-note reports. That keeps the project maintainable as more vocabulary, languages, and learning modes are added.

## Roadmap

- Add more language pairs beyond German and Spanish
- Import/export custom decks
- Add richer CEFR placement diagnostics
- Add pronunciation scoring
- Improve offline-first sync conflict handling
- Publish a small reusable Swift package for the scheduler

## Discoverability

- Public landing page: [`docs/index.html`](docs/index.html)
- Contributor guide: [`CONTRIBUTING.md`](CONTRIBUTING.md)
- Architecture map: [`docs/architecture.md`](docs/architecture.md)
- Vocabulary contribution guide: [`docs/vocabulary-contribution-guide.md`](docs/vocabulary-contribution-guide.md)
- Vocabulary quality audit: [`docs/vocabulary-quality-audit.md`](docs/vocabulary-quality-audit.md)
- Release checklist: [`docs/release-checklist.md`](docs/release-checklist.md)
- Changelog: [`CHANGELOG.md`](CHANGELOG.md)

## Contributing

Contributions are welcome. Good first areas:

- add vocabulary cards with CEFR tags
- improve scheduling tests
- polish accessibility labels
- add localization strings
- improve docs for language learners and SwiftUI developers

See `CONTRIBUTING.md` for details. Vocabulary contributors can start with `docs/vocabulary-contribution-guide.md`, then use `docs/vocabulary-quality-audit.md` before review. Maintainers preparing public builds or release notes can use `docs/release-checklist.md`.

## License

MIT
