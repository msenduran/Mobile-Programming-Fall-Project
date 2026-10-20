# Öğrenci Evim

A mobile app for students who share a flat. Housemates track rent and utility bills together,
see who paid what and who owes whom, and talk in a private house chat. Everything about the
house's money is visible to everyone in the house, so nobody has to ask twice.

> Term project for the **Mobile Programming** course, İstanbul University-Cerrahpaşa,
> 2026-2027 Fall. The full assignment is in [`Project.txt`](Project.txt).

## Features

**Core**
- Create a house and invite housemates with a join code
- Track rent and bills (water, electricity, gas, internet): amount, due date, who paid, each person's share
- Balance summary: who owes whom
- Local notification before a payment is due
- House chat (after the Firebase phase, see below)

**Later**
- Cleaning / chore rotation
- Shared shopping list

**Future ideas**
- A search section where houses or rooms can be listed

## Roadmap

| Phase | Storage | Goal |
|---|---|---|
| 1. Midterm prototype | SQLite only | Houses, members, bills and balances working on one device. Housemates are simulated with a "switch user" option. |
| 2. After midterm | SQLite + Firebase | Real sync between housemates' phones and the house chat. SQLite stays as the offline cache. |
| 3. Later | | Chores, shopping list, then the listings idea. |

## Tech stack

| Area | Choice |
|---|---|
| Framework | Flutter (Dart), Android first |
| State management | `provider` (`ChangeNotifier`) |
| Navigation | Flutter `Navigator` with named routes |
| Local database | `sqflite` |
| Key-value settings | `shared_preferences` |
| Networking | `http`, hand-written JSON (de)serialization |
| Localization | `flutter_localizations` + `intl` (Turkish, English) |
| Remote backend | Firebase (phase 2) |

Why each one was picked and how the code is organized: [`docs/architecture.md`](docs/architecture.md).

## Getting started

Requirements: Flutter SDK (3.47 or newer), Android Studio with an Android emulator.

```bash
git clone <repo-url>
cd <repo>/app
flutter pub get
flutter emulators --launch <emulator-id>   # `flutter emulators` lists them
flutter run
```

The Flutter project lives in `app/`. If `flutter doctor` reports problems, fix them before the
first run.

## Repository layout

```
app/          # Flutter project (source code)
docs/         # architecture, scope & work plan, weekly reports, final report
docs/weekly/  # week-XX.md progress reports
```

## Contributing

Read [`CONTRIBUTING.md`](CONTRIBUTING.md) before your first commit. In short: one branch per task,
every change goes through a pull request, and everyone commits from their own GitHub account.
