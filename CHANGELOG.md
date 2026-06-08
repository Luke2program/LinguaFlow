# Changelog

All notable changes to LinguaFlow are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- `CHANGELOG.md` to track releases and help contributors follow project history.
- Feature request issue template for general enhancement proposals.

### Changed
- Contributor landing page (`docs/contributing.html`) now links to architecture map, vocabulary audit, and release checklist.

## [0.2.1] - 2026-06-05

### Added
- Vocabulary quality audit guide (`docs/vocabulary-quality-audit.md`).
- Release checklist (`docs/release-checklist.md`) for maintainers.
- Public contributor landing page (`docs/contributing.html`).

### Changed
- `CONTRIBUTING.md` updated with vocabulary review steps.
- README Discoverability section expanded with new docs.

## [0.2.0] - 2026-06-01

### Added
- Public project landing page (`docs/index.html`) with feature grid and contributor links.
- Contributor architecture guide (`docs/architecture.md`).
- Vocabulary contribution guide (`docs/vocabulary-contribution-guide.md`).
- GitHub issue templates for bug reports and vocabulary contributions.
- Pull request template for focused, well-documented changes.
- Maintainer Signal automation (`maintainer-signal.yml` workflow).
- Launch materials (`LAUNCH.md`).
- `CODE_OF_CONDUCT.md` and `SECURITY.md`.

### Changed
- README badges, install instructions, and roadmap updated for open-source discoverability.
- CI workflow (`ios.yml`) builds on every push and pull request.

## [0.1.0] - 2026-05-20

### Added
- Initial release: German-Spanish vocabulary trainer with CEFR onboarding.
- SM-2 inspired spaced repetition scheduler with ease, interval, and lapse tracking.
- Bidirectional review (German to Spanish and Spanish to German).
- Offline speech audio via `AVSpeechSynthesizer`.
- Daily streaks, XP, gems, combo feedback, and fluency meter.
- SwiftUI interface with accessibility identifiers for UI testing.
- Unit tests for scheduler, answer evaluation, and vocabulary data.
- UI tests for review flow, settings, and account entry points.
