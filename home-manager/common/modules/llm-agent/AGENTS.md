# AGENTS.md

## Language

- User-facing replies
    - Default: Japanese
    - When the user asks for another language: that language

## Git

- Before running `git add`, check the changes with `git status` and `git diff`.
- Use `git rm` instead of `rm` for files tracked by git.
- Write commit messages in English with a conventional commit prefix.
    - `feat:`
    - `fix:`
    - `docs:`
    - `style:`
    - `refactor:`
    - `test:`
    - `chore:`
- Keep each commit small enough that one subject line describes the whole change.

## Pull Requests

- Write only what you changed in the PR body, in three lines or fewer.

## What Goes Where

- Application code
    - Code: how it works
    - Comments: why not, such as the alternative you rejected and the reason
- Test code
    - Code: what behavior it checks

## Comments

- When you modify a comment
    - Rewrite the whole comment so it does not read like revision history.

@RTK.md
