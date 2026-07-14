# Noor ul Haya

Islamic prayer companion built with Flutter: accurate prayer times, reliable alarms, accountability flows, Quran reminders, and spiritual tracking.

**Live showcase:** `index.html` at repo root. Works on Vercel (auto) and [GitHub Pages](https://usmanghias.github.io/noor/) (enable **Settings → Pages → Source: GitHub Actions**).

**Version:** 1.0.0  
**Architecture:** Clean Architecture + Feature First  
**State Management:** Riverpod  
**Navigation:** GoRouter  
**Database:** Hive (+ Isar/Drift when complex querying is needed)  
**Target Platforms:** Android (first), iOS (second)

---

## Requirements

- Flutter (latest stable channel)
- Dart 3.8+
- **Java 17 or 21** for Android builds (Java 25 is not supported yet)
- Android SDK 24+ (Android 7.0+), compile SDK 36
- Xcode 15+ (for iOS builds, macOS only)

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Required on this machine if default Java is 25+
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64

# Generate code (Freezed, Riverpod, Hive adapters)
dart run build_runner build --delete-conflicting-outputs

# Run static analysis
flutter analyze --fatal-infos

# Run tests
flutter test

# Build Android (verify compile)
flutter build apk --debug

# Run on a connected device or emulator
flutter run
```

---

## Project Structure

```
lib/
├── core/                 # Shared infrastructure
│   ├── config/           # App config, routing
│   ├── constants/
│   ├── errors/
│   ├── extensions/
│   ├── theme/
│   ├── widgets/
│   ├── utils/
│   ├── services/
│   ├── repositories/
│   ├── models/
│   └── localization/
├── features/             # Feature modules (Clean Architecture)
│   └── <feature>/
│       ├── presentation/
│       ├── domain/
│       └── data/
├── app.dart
└── main.dart
```

Each feature is self-contained so Cursor AI agents can work on independent modules with minimal merge conflicts.

---

## Development Roadmap

| Phase | Module | Status |
|-------|--------|--------|
| 0 | Project initialization | Done |
| 1 | Folder structure | Done |
| 2 | Theme system | Planned |
| 3 | Splash screen | Planned |
| 4 | Onboarding | Planned |
| 5 | Location | Planned |
| 6 | Prayer time engine | Planned |
| 7 | Home dashboard | Planned |
| 8 | Alarm engine | Planned |
| 9 | Accountability flow | Planned |
| 10 | Speech recognition | Planned |
| 11 | QR scanner | Planned |
| 12 | Quran module | Planned |
| 13 | Hadith module | Planned |
| 14 | Streak engine | Planned |
| 15 | Statistics | Planned |
| 16 | Settings | Planned |
| 17 | Notification engine | Planned |
| 18 | Offline storage | Planned |
| 19 | Cloud sync (optional) | Planned |
| 20 | Localization | Planned |
| 21 | Home screen widgets | Planned |
| 22 | Wearables (future) | Planned |
| 23 | Testing (80%+ coverage) | Planned |
| 24 | Release | Planned |

---


## Open Source Collaboration

Noor ul Haya was opened for worldwide community collaboration on July 14, 2026, the project's Open Source Day. The goal is to improve the Quran Majeed and namaz experience for Muslims around the world while keeping the work open, respectful, and source-backed.

Everyone is welcome to contribute through issues, discussions, forks, and pull requests. The maintainers may use accepted community contributions to improve the published Google Play version after review, testing, and release approval.

Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request. Important rules include:

- Keep Quran, hadith, namaz, and Islamic guidance changes accurate, respectful, and supported by reliable sources.
- Do not include secrets, signing keys, Play Store credentials, private analytics keys, or user data.
- Keep pull requests focused and include testing notes.
- Add screenshots for visible UI changes.
- Follow the GNU AGPLv3 or later license requirements for forks and redistributed versions.

---

## Cursor Agent Workflow

Use specialized agents in sequence to reduce conflicts:

| Agent | Responsibility |
|-------|----------------|
| Architecture Agent | Structure, DI, routing |
| UI Agent | Material 3, design system |
| Prayer Engine Agent | Prayer calculations, location |
| Alarm Agent | Notifications, exact alarms, foreground services |
| Islamic Content Agent | Quran, hadith, localization content |
| Data Agent | Hive, repositories, sync-ready persistence |
| Testing Agent | Unit, widget, integration tests, CI |
| Release Agent | Store assets, build optimization |

---

## CI

GitHub Actions runs on every push and pull request:

- `flutter analyze`
- `flutter test`
- `flutter build apk --debug` (Android compile check)

---

## License

Noor ul Haya is open source under the GNU Affero General Public License v3.0 or later. See [LICENSE](LICENSE).

This strong copyleft license is used so the app can stay open for everyone. You may use, study, share, and improve the code, but redistributed versions and qualifying modified network versions must also provide source code under the same license terms.
