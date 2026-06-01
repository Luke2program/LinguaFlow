# Contributing

Thanks for helping improve LinguaFlow.

## Development

Open the project in Xcode:

```bash
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

## Contribution Areas

Useful contributions include:

- vocabulary additions with level, category, examples, and hints
- scheduler improvements backed by unit tests
- accessibility improvements for UI tests and VoiceOver
- additional language-pair architecture
- documentation for learners or SwiftUI developers

## Vocabulary Guidelines

Each vocabulary card should include:

- natural German and Spanish text
- a CEFR level
- a short category
- example sentences in both languages
- a learner-friendly hint

Avoid adding copyrighted course material or copied dictionary content.

## Pull Requests

Please include:

- what learner or developer problem the change solves
- screenshots for UI changes
- tests for scheduler, answer evaluation, or persistence changes
- updated docs when behavior changes
