# Architecture

This document explains how the Öğrenci Evim code is organized and why. Read it before adding a
new screen, table or package.

The structure is a simplified version of Flutter's official
[app architecture guide](https://docs.flutter.dev/app-architecture) and its sample app
[Compass](https://github.com/flutter/samples/tree/main/compass_app). The course follows
flutter.dev, so everything here can be traced back to the course material.

## Tech stack and where it comes from

| Area | Choice | Course week | Notes |
|---|---|---|---|
| UI | Flutter, Material widgets | 1–3 | |
| Navigation | `Navigator`, named routes | 4 | No `go_router`; the course teaches `Navigator`. |
| Images | `cached_network_image` | 4 | Only when we show images from the internet. |
| Localization | `flutter_localizations` + `intl` | 4 | Turkish and English. |
| State management | `provider` + `ChangeNotifier` | 5 | The "Simple app state management" approach on flutter.dev. |
| Local database | `sqflite` | 5 | `floor` (ORM) was also suggested in class but hasn't been updated in 2 years. We may try it later in a separate branch. |
| IDs | `uuid` | – | Row ids that stay unique when we move to Firebase. |
| Tests | `flutter_test`, `sqflite_common_ffi` | – | `sqflite_common_ffi` runs the real SQLite tables on the computer in database tests. |
| Settings | `shared_preferences` | 5 | Current user, language and other small values. |
| Networking | `http`, hand-written `fromJson` / `toJson` | 5 | No code generation, so every line can be explained. |
| Remote backend | Firebase (Auth, Firestore) | 7 | Phase 2, for sync and chat. |

**Not used on purpose:** `go_router`, `freezed`, `json_serializable`, BLoC, Riverpod. They are good
tools, but they are outside the course and make the code harder to explain in the presentation.

## Layers

```
Screen (widget)
   │  watches / calls
   ▼
ViewModel (ChangeNotifier)
   │  calls
   ▼
Repository (abstract class)
   │  implemented by
   ▼
Repository implementation (_sqlite now, _firebase later)
   │  uses
   ▼
Service (sqflite database, notifications, shared_preferences, http)
```

Each layer only talks to the one directly below it:

- **Screens** draw the UI and forward user actions to their ViewModel. They never touch the
  database or a repository.
- **ViewModels** hold the screen's state, call repositories and call `notifyListeners()` when
  something changes. They don't import `sqflite` or Firebase.
- **Repositories** are the single source of truth for one kind of data (houses, bills, ...).
  The abstract class says *what* can be done; the implementation decides *how*.
- **Services** wrap one external thing (the SQLite file, the notification plugin, ...) and know
  nothing about screens.
- **Models** (`domain/models/`) are plain Dart classes used by every layer.

## Folder structure

```
app/
├── lib/
│   ├── main.dart                 # runApp and provider setup
│   ├── app.dart                  # MaterialApp, theme, routes
│   ├── config/
│   │   └── dependencies.dart     # which repository implementations are used
│   ├── domain/
│   │   └── models/               # house.dart, member.dart, bill.dart, bill_share.dart (message.dart in phase 2)
│   ├── data/
│   │   ├── repositories/
│   │   │   ├── house/            # house_repository.dart, house_repository_sqlite.dart
│   │   │   ├── bill/             # bill_repository.dart, bill_repository_sqlite.dart
│   │   │   └── chat/             # chat_repository.dart (+ _firebase in phase 2)
│   │   └── services/
│   │       ├── database/
│   │       │   └── app_database.dart   # opens SQLite, creates tables, migrations
│   │       ├── notification_service.dart
│   │       └── preferences_service.dart
│   ├── ui/
│   │   ├── core/                 # theme, shared widgets
│   │   ├── home/                 # first screen, tabs for bills / balances / chat
│   │   ├── house/                # create / join a house
│   │   │   ├── view_models/
│   │   │   └── widgets/
│   │   ├── bills/                # bill list, bill form
│   │   ├── balances/             # who owes whom
│   │   ├── chat/
│   │   └── settings/             # switch user (phase 1), language
│   ├── routing/
│   │   └── routes.dart           # route names and the route table
│   ├── l10n/                     # app_tr.arb, app_en.arb
│   └── utils/                    # money/date formatting, id generation (id.dart)
└── test/                         # mirrors lib/
```

UI code is grouped **by feature** (`ui/bills/`, `ui/chat/`, ...), so each feature has its own
folder and an owner who can explain it. Data code is grouped **by layer** (`repositories/`,
`services/`) because several features share it.

## Repository pattern (and the move to Firebase)

Every repository is an abstract class with one implementation per storage:

```dart
// data/repositories/bill/bill_repository.dart
abstract class BillRepository {
  Future<List<Bill>> getBills(String houseId);
  Future<void> addBill(Bill bill);
  Future<void> markPaid(String billId, String memberId);
}

// data/repositories/bill/bill_repository_sqlite.dart
class BillRepositorySqlite implements BillRepository {
  BillRepositorySqlite(this._db);
  final AppDatabase _db;
  // ... SQL queries here
}
```

`config/dependencies.dart` decides which implementation the app uses:

```dart
Provider<BillRepository>(create: (_) => BillRepositorySqlite(database)),
```

In phase 2 we add `BillRepositoryFirebase` next to it and change this one line. Screens and
ViewModels stay the same.

## Database design rules

These rules are there so the move to Firebase in phase 2 is an addition, not a rewrite.

- **IDs are UUID strings**, generated in the app, not SQLite `AUTOINCREMENT` integers. The same
  id can then be used in Firestore.
- **Every row that belongs to a house has a `house_id`** and, where relevant, a `member_id` /
  `created_by`.
- **Money is stored as an integer in kuruş** (`amount_kurus`, e.g. 1250.50 TL → `125050`). No
  floating-point rounding errors when splitting bills.
- **Dates are stored as UTC milliseconds since epoch** (`INTEGER`) and formatted only in the UI.
- **Schema changes bump the database version** in `app_database.dart` and add a migration step in
  `onUpgrade`. Never edit an existing `CREATE TABLE` in a way that breaks installed apps.

Tables (database version 1, defined in `app_database.dart`):

| Table | Main columns | Model |
|---|---|---|
| `houses` | `id`, `name`, `invite_code` (unique), `created_at` | `House` |
| `members` | `id`, `house_id`, `name`, `created_at` | `Member` |
| `bills` | `id`, `house_id`, `title`, `category`, `amount_kurus`, `due_date`, `paid_by` (null = not paid yet), `created_by`, `created_at` | `Bill` |
| `bill_shares` | `bill_id` + `member_id` (primary key), `amount_kurus`, `paid_at` (null = still owes) | `BillShare` |
| `messages` | `id`, `house_id`, `member_id`, `text`, `sent_at` (phase 2) | – |

How a bill is paid: one member pays the whole bill and becomes `paid_by`. Every other member then
owes their share to that member until their `bill_shares.paid_at` is set. The payer's own share
counts as paid. Shares are made with `splitEvenly` in `utils/money.dart`, which gives leftover
kuruş to the first members so the shares always add up to the bill.

Deleting a house deletes its members, bills and shares (`ON DELETE CASCADE`). Balances ("who owes
whom") are calculated from `bills` and `bill_shares`; they are not stored.

Models are plain classes with `toMap()` / `fromMap()` that use the column names above. Enums such
as `BillCategory` are stored by name (`'electricity'`), not by index, so reordering them is safe.

## State management rules

- One ViewModel per screen (or per closely related group of screens).
- ViewModels extend `ChangeNotifier` and are provided with `ChangeNotifierProvider`.
- Short-lived UI state (a text field, an open dropdown) stays in a `StatefulWidget`. This is the
  "ephemeral vs app state" split from the course.
- Use `context.watch` in `build` to redraw, and `context.read` in callbacks to call methods.

## Localization

All user-facing text goes in `lib/l10n/app_tr.arb` and `app_en.arb`. Don't hard-code strings in
widgets. Turkish is the default language.
