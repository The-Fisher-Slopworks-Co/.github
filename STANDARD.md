<!--
SPDX-FileCopyrightText: 2026 The Fisher Slopworks Co
SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Engineering standard

What every active The Fisher Slopworks Co repository carries beyond licensing.
Licensing and REUSE are in [COMPLIANCE.md](COMPLIANCE.md). The reference
implementation is [`any_talker`](https://github.com/The-Fisher-Slopworks-Co/any_talker):
when this page and any_talker disagree, any_talker is the newer one and this page
should be updated.

There is no template repository to start from. A new repo and an old one are
brought to the standard the same way: run the `slopworks-standardize` Claude
skill (or follow the checklist below by hand) on a branch and open a PR. It adds
what is missing and leaves what is already there.

Archived repositories are out of scope.

## Layer A: every repository

| # | What | Where | Notes |
|---|---|---|---|
| A1 | Licensing and REUSE | see [COMPLIANCE.md](COMPLIANCE.md) | REUSE CI calls the reusable `reuse.yml` |
| A2 | `CLAUDE.md` + `AGENTS.md` | repo root | `AGENTS.md` is a symlink to `CLAUDE.md`. Covers commands, layout, conventions and the Definition of done below |
| A3 | Definition of done | `CLAUDE.md` | copy the section below, adjusting the gate command and scopes |
| A4 | PR title check | `.github/workflows/pr-title.yml` | calls the reusable `pr-title.yml` with the repo's scopes |
| A5 | PR size labels | `.github/workflows/pr-size.yml` | calls the reusable `pr-size.yml` |
| A6 | PR and issue templates | inherited | from this repo's `.github/`; a repo adds its own only to extend the checklist |
| A7 | `CODEOWNERS` | `.github/CODEOWNERS` | `* @txssu` |
| A8 | Dependabot | `.github/dependabot.yml` | snippet below |
| A9 | CI gate | `.github/workflows/ci.yml` (+ `check.yml` when a release workflow reuses it) | runs the repo's whole check gate on PRs to main, `permissions: contents: read`, `concurrency` per ref |
| A10 | Pinned third-party actions | all workflows | actions outside `actions/*`, `github/*` and the stack's official setup action are pinned by SHA with a `# vX.Y.Z` comment |
| A11 | Claude Code settings | `.claude/settings.json` | enabled plugins: `claude-md-management`, `commit-commands`, plus the stack's LSP plugin |
| A12 | PR settings and ruleset | GitHub settings | applied by [scripts/repo-settings.sh](scripts/repo-settings.sh), see [Pull request settings](#pull-request-settings) |

Optional: `.github/labeler.yml` + a `pr-labels.yml` job for `area:*` labels in
repos big enough to have areas, and `.git-blame-ignore-revs` once a
reformat-only commit exists.

## Layer B: TypeScript / Bun

| # | What | Where |
|---|---|---|
| B1 | Bun as runtime, package manager and test runner (`bun.lock`, `bun test`) | `package.json` |
| B2 | One gate: `bun run check` = typecheck + lint + format:check + knip + reuse + test | `package.json` scripts |
| B3 | oxlint, `correctness` and `suspicious` as errors; every disabled rule has a comment saying why | `.oxlintrc.json` |
| B4 | Prettier: 80 columns, double quotes, trailing commas, `arrowParens: always` | `.prettierrc.json` |
| B5 | knip for unused files, exports and dependencies | `knip.ts` |
| B6 | lefthook pre-commit running the same gate (`"prepare": "lefthook install"`); checks, never rewrites, staged files | `lefthook.yml` |
| B7 | Strict TypeScript: `strict`, `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, `noUnusedLocals`, `noUnusedParameters`, `noImplicitReturns`, `noImplicitOverride`, `verbatimModuleSyntax` | `tsconfig.json` |
| B8 | `"license": "AGPL-3.0-or-later"` | `package.json` |

Copy the config files from any_talker and trim what does not apply (its
`knip.ts` entries, for one, are specific to it).

Projects that are not built with Bun keep their toolchain and take the
equivalent of B2–B7 in it: VS Code extensions stay on npm with oxlint, Prettier,
knip, lefthook and the strict tsconfig; Go projects use golangci-lint and
`go test` as their gate.

## Layer C: deployed services

| # | What | Where |
|---|---|---|
| C1 | Dockerfile; `release.yml` on push to main runs the gate, then builds and publishes to GHCR (`latest`, long and short SHA tags) | `Dockerfile`, `.github/workflows/release.yml` |
| C2 | Preview image from a PR by commenting `/deploy` (members only, no forks) | `.github/workflows/pr-deploy.yml` |
| C3 | `.env.example` and `docker-compose.yml` | repo root |

## Definition of done

The section every `CLAUDE.md` carries. Replace `bun run check` and the scope
list with the repo's own.

```markdown
### Definition of done

- **Issues and pull requests are written in English** — title and body, whatever language the task was discussed in.
- **Never commit to main.** Every task starts on a fresh branch off `origin/main`, named `<type>/<short-task>` — `fix/`, `feat/`, `refactor/`, `chore/`.
- **One task = one branch = one PR.** Past ~300 changed lines, split it into several PRs. `size:XL` or `size:XXL` means split the PR, not "explain why it is large".
- **PR title is the squash commit subject:** conventional commit with a scope, enforced by `.github/workflows/pr-title.yml`.
  - Type: `feat` `fix` `refactor` `chore` `docs` `test` `ci` `perf` `revert`.
  - Scope (required): one of the scopes listed in that workflow. A new module means adding it there.
  - Subject: lowercase start, imperative, no trailing period.
  - The body describes this PR alone, following the PR template.
- **No AI attribution.** No `Assisted-by:` / `Co-Authored-By: <LLM>` trailers and no "Generated with …" lines. The PR body becomes the squash commit body, so the PR title workflow fails a PR that carries one.
- **Before opening:** `bun run check` green, then open the PR and report its URL.
- **Never merge locally.** Merging happens on GitHub, squash only.
```

## Reusable workflows

Defined in this repo under `.github/workflows/`; each file's header has the full
caller snippet.

| Workflow | Caller trigger | Inputs |
|---|---|---|
| `reuse.yml` | `push` / `pull_request` on main | none |
| `pr-title.yml` | `pull_request` (`opened`, `edited`, `synchronize`, `reopened`) | `scopes` (one per line, empty = any), `require-scope` (default `true`) |
| `pr-size.yml` | `pull_request_target` (`opened`, `synchronize`, `reopened`, `ready_for_review`) | `exclude` (extra path regexes) |

A reusable workflow cannot get more permissions than its caller grants, so the
caller's `permissions:` block has to match the one in the snippet.

## Dependabot

Package updates arrive only as security fixes; GitHub Actions update weekly
after a week's cooldown. Use the repo's package ecosystem (`bun`, `npm`,
`gomod`, …) in the first block, or drop it if the repo has no packages.

```yaml
# SPDX-FileCopyrightText: 2026 The Fisher Slopworks Co
#
# SPDX-License-Identifier: AGPL-3.0-or-later

version: 2

updates:
  - package-ecosystem: bun
    directory: /
    schedule:
      interval: weekly
    open-pull-requests-limit: 0
    commit-message:
      prefix: chore(deps)
    groups:
      security:
        applies-to: security-updates
        patterns: ["*"]

  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
    cooldown:
      default-days: 7
    commit-message:
      prefix: chore(deps)
    groups:
      actions:
        update-types: [minor, patch]
```

## Pull request settings

Every active repository merges the same way. Run
[`scripts/repo-settings.sh`](scripts/repo-settings.sh) once per repo (and again
whenever its CI check names change). It is idempotent:

```bash
scripts/repo-settings.sh <repo> "<CI gate check name>" "<REUSE check name>"
```

It sets:

- **Merging:** squash only. The commit title is the PR title and the body is
  the PR body. The head branch is deleted after merge. Auto-merge is off.
- **Ruleset `main` on the default branch:** no deletion and no force-push.
  Changes go in only through a squash-merged PR with every review thread
  resolved, 0 required approvals, and the given status checks green on an
  up-to-date branch. Repository admins can bypass it.

Required checks are the job names as GitHub reports them on a PR (for example
`check / Type check & tests` and `REUSE compliance` in any_talker). When a repo
switches to the reusable workflows, its check names change, so rerun the script
with the new names.
