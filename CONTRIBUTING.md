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
