# Contributing Rules

Rules for everyone working on this repo. Please read before your first commit.

## Golden rules

1. **Never push directly to `main`.** `main` must always build and run.
2. **One branch per task.** Keep branches small and merge them quickly.
3. **Every change goes through a Pull Request** and is reviewed by at least one teammate.
4. **Pull `main` often** so you don't drift away from the others.

## Contribution share (important)

The assignment requires every member to appear as a contributor on GitHub and to have written
**at least 5%** of the code. This is measured from GitHub's statistics, so:

- Everyone commits **from their own computer, with their own account**. Never commit someone else's code on their behalf.
- Your commit email must be linked to your GitHub account, otherwise your commits won't count for you:
  ```bash
  git config user.name  "<your-github-username>"
  git config user.email "<email linked to your GitHub account>"
  ```
  To keep your email private, use the `<id>+<username>@users.noreply.github.com` address
  from GitHub → Settings → Emails.

## Branch naming

| Prefix      | Use for                    | Example                  |
|-------------|----------------------------|--------------------------|
| `feature/`  | New functionality          | `feature/login-screen`   |
| `fix/`      | Bug fixes                  | `fix/sqlite-migration`   |
| `docs/`     | Documentation / reports    | `docs/week-07`           |

## Daily workflow

```bash
# 1. Start from an up-to-date main
git checkout main
git pull

# 2. Create your branch
git checkout -b feature/<task-name>

# 3. Work, then commit
git status
git add <file1> <file2>
git commit -m "Short, clear message"

# 4. Push (-u only on the first push)
git push -u origin feature/<task-name>
git push

# 5. Get the latest main into your branch when needed
git pull origin main
```

Then open a Pull Request on GitHub with the **"Compare & pull request"** button.

## Commits

- One logical change per commit.
- The message says what it does: `Add note list screen`, `Fix crash on empty database`.
- Use `git add <files>` instead of `git add .` so you don't commit things by accident.
- Build output (`build/`, `.dart_tool/`) and IDE files are not committed.

## Pull Requests

- Title: short summary of the change.
- Description: fill in the PR template (what changed, how it was tested, `Closes #<issue>` if any).
- Before asking for review:
  ```bash
  flutter analyze
  dart format .
  flutter test
  ```
  and make sure the app launches on the emulator.
- After approval, the PR author merges and deletes the branch.
- PRs also show who did what in the weekly reports. Add links to the PRs merged that week
  to the weekly report.

## Code

Questions about the source code may come up during the presentation. Keep the code readable,
and make sure everyone can explain the parts they wrote.

Read [`docs/architecture.md`](docs/architecture.md) first. The short version:

### Where does my code go?

| I'm adding... | Put it in |
|---|---|
| A new screen | `lib/ui/<feature>/widgets/<name>_screen.dart` |
| State/logic for that screen | `lib/ui/<feature>/view_models/<name>_view_model.dart` |
| A data class (Bill, Member, ...) | `lib/domain/models/<name>.dart` |
| A way to read/write some data | `lib/data/repositories/<thing>/<thing>_repository.dart` (abstract) + `<thing>_repository_sqlite.dart` |
| A new table or column | `lib/data/services/database/app_database.dart`, **bump the version and add a migration** |
| A widget used by several features | `lib/ui/core/` |
| A new route | `lib/routing/routes.dart` |
| User-facing text | `lib/l10n/app_tr.arb` **and** `app_en.arb` |

### Layer rules

- Screens don't call repositories or the database. They talk to their ViewModel.
- ViewModels don't import `sqflite` or Firebase. They talk to repositories.
- ViewModels and screens depend on the **abstract** repository (`BillRepository`), never on
  `BillRepositorySqlite`. Only `config/dependencies.dart` knows which implementation is used.

### Naming

- Files and folders: `snake_case` (`bill_list_screen.dart`).
- Classes: `PascalCase` (`BillListScreen`, `BillListViewModel`).
- Suffixes show the role: `_screen`, `_view_model`, `_repository`, `_repository_sqlite`, `_service`.
- Database columns: `snake_case` (`amount_kurus`, `house_id`). Dart fields: `camelCase` (`amountKurus`).

### Data rules

- IDs are UUID strings, money is an `int` in kuruş, dates are stored as UTC milliseconds.
- Every house-related row has a `house_id`.

### Packages

Don't add a new package to `pubspec.yaml` without talking to the team first. Every package is
something we may have to explain in the presentation.

### Tests

Put tests in `test/` using the same folder structure as `lib/`. ViewModels and repositories are
the most useful things to test.
