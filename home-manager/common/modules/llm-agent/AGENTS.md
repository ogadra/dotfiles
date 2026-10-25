# AGENTS.md

## Language

- User-facing replies
    - Default: Japanese
    - Another language the user asks for: that language

## Git

- Before running `git add`
    - Check the changes with `git status`.
    - Check the changes with `git diff`.
- Use `git rm` instead of `rm` for files tracked by git.
- Write commit messages in English.
- Start each commit message with a conventional commit prefix.
    - `feat:`
    - `fix:`
    - `docs:`
    - `style:`
    - `refactor:`
    - `test:`
    - `chore:`
- Keep each commit small enough that one subject line describes the whole change.

## Pull Requests

- PR body
    - Write only what you changed.
    - Keep it to three lines or fewer.

## What Goes Where

- Application code
    - Code: how it works
    - Comments: why not
        - The alternative you rejected
        - The reason you rejected it
- Test code
    - Code: what behavior it checks

## Comments

- Modifying a comment
    - Rewrite the whole comment so it does not read like revision history.

## Commands for the User to Run

- When the user needs to run a command themselves, copy it to the clipboard with `@clipboardCommand@`.

## Questions for the User

- When you need answers from the user
    - Put all the questions together at the end of your reply.
    - List every unanswered question each time, including ones you asked in earlier replies.
    - Do not point the user to earlier replies such as "the ... in my previous report"; give enough background, options, and your recommendation with its reason for the user to decide on the spot.

@RTK.md
